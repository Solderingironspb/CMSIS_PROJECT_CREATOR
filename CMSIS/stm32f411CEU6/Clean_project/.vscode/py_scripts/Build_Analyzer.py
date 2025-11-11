#   Build Analyzer v 1.2 (Переписан под python 3 для более легкого парсинга JSON)
#   Автор: Волков Олег
#   Дата создания скрипта: 09.11.2025
#   GitHub: https://github.com/Solderingironspb
#   Группа Вконтакте: https://vk.com/solderingiron.stm32
#   YouTube: https://www.youtube.com/channel/UCzZKTNVpcMSALU57G1THoVw
#   RuTube: https://rutube.ru/channel/36234184/
#   Яндекс Дзен: https://dzen.ru/id/622208eed2eb4c6d0cd16749

import subprocess
import json
import sys
import os
import re

# Цвета для терминала
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'

def print_error(message):
    #Вывод ошибки красным цветом
    print(f"{Colors.RED}{Colors.BOLD}{message}{Colors.END}")

def print_warning(message):
    #Вывод предупреждения желтым цветом
    print(f"{Colors.YELLOW}{message}{Colors.END}")

def print_success(message):
    #Вывод успешного сообщения зеленым цветом
    print(f"{Colors.GREEN}{message}{Colors.END}")

def print_info(message):
    #Вывод информационного сообщения синим цветом
    print(f"{Colors.WHITE}{message}{Colors.END}")

def print_header(message):
    #Вывод заголовка
    print(f"{Colors.BOLD}{Colors.GREEN}{message}{Colors.END}")

def parse_memory_size(size_str):
    #Конвертирует строку размера (64K, 128K, 1M) в байты
    match = re.search(r'(\d+)([KkMm]?)', str(size_str))
    if match:
        size = int(match.group(1))
        unit = match.group(2).upper()
        
        if unit == 'K':
            return size * 1024
        elif unit == 'M':
            return size * 1024 * 1024
        else:
            return size
    return 0

def analyze_elf_file(elf_file, map_file, json_config_path, memory_details):
    #Основная функция анализа
    
    # Проверка существования файлов
    if not os.path.exists(elf_file):
        print_error(f"Ошибка: Файл {elf_file} не найден")
        return
    
    if not os.path.exists(map_file):
        print_error(f"Ошибка: Файл {map_file} не найден")
        return
    
    # 1. Чтение конфигурации из JSON
    memory_config = read_memory_config(json_config_path)
    
    # 2. Запуск arm-none-eabi-size
    size_output = run_arm_none_eabi_size(elf_file, memory_details)
    
    # 3. Парсинг секций
    section_sizes = parse_section_sizes(size_output)
    
    # 4. Расчет использования памяти
    memory_usage = calculate_memory_usage(section_sizes, memory_config)
    
    # 5. Вывод результатов
    print_memory_report(memory_usage, memory_config)
    
    # 6. Дополнительная информация
    #print_additional_info(memory_usage, memory_config)

def read_memory_config(json_config_path):
    #Чтение конфигурации памяти из JSON файла - универсальная версия
    
    # Базовая конфигурация по умолчанию
    config = {
        'memory_blocks': {
            'RAM': {
                'origin': '0x20000000',
                'bytes': 20 * 1024,
                'type': 'RAM'
            },
            'FLASH': {
                'origin': '0x08000000', 
                'bytes': 64 * 1024,
                'type': 'FLASH'
            }
        },
        'section_mapping': {}
    }
    
    if not os.path.exists(json_config_path):
        print_warning(f"JSON файл не найден: {json_config_path}")
        print_warning("Используются значения по умолчанию")
        return config
    
    try:
        # Проверяем размер файла
        file_size = os.path.getsize(json_config_path)
        print_info(f"Размер JSON файла: {file_size} bytes")
        
        if file_size == 0:
            print_warning("Файл пустой, используются значения по умолчанию")
            return config
        
        # Чтение JSON
        with open(json_config_path, 'r', encoding='utf-8') as f:
            content = f.read().strip()
            
        if not content:
            print_warning("Файл пустой после удаления пробелов")
            return config
            
        json_content = json.loads(content)
        print_success("Успешно прочитан JSON конфигурации")
        
        # Загрузка memory_blocks
        if 'memory_blocks' in json_content:
            config['memory_blocks'] = {}
            for block_name, block_data in json_content['memory_blocks'].items():
                config['memory_blocks'][block_name] = {
                    'origin': block_data.get('origin', '0x0'),
                    'bytes': block_data.get('bytes', parse_memory_size(block_data.get('length', '0'))),
                    'type': block_data.get('type', 'UNKNOWN'),
                    'attributes': block_data.get('attributes', '')
                }
                print_info(f"{block_name}: {config['memory_blocks'][block_name]['bytes']} bytes at {config['memory_blocks'][block_name]['origin']}")
        
        # Анализ распределения секций
        if 'sections' in json_content:
            section_mapping = analyze_section_mapping(json_content['sections'])
            config['section_mapping'] = section_mapping
                
        return config
        
    except Exception as e:
        print_error(f"Критическая ошибка чтения JSON: {e}")
        print_warning("Используются значения по умолчанию")
        return config

def analyze_section_mapping(sections_data):
    #Универсальный анализ распределения секций из JSON
    section_mapping = {}
    
    print_header("\nАнализ распределения секций:")
    
    for section in sections_data:
        section_name = section['name']
        section_type = section['type']
        location = section.get('location', '')
        load_memory = section.get('load_memory', '')
        
        # Определяем тип размещения
        if '->' in section_type:
            # Секции, которые хранятся в одном месте, выполняются в другом
            parts = section_type.split('->')
            storage_memory = parts[0].strip()
            execution_memory = parts[1].strip()
            mapping_type = 'STORED_EXECUTED'
        else:
            # Секции только в одном месте
            storage_memory = section_type
            execution_memory = section_type
            mapping_type = 'SINGLE'
        
        section_mapping[section_name] = {
            'storage_memory': storage_memory,
            'execution_memory': execution_memory,
            'mapping_type': mapping_type,
            'description': section.get('description', '')
        }
        
        print_info(f"{section_name} -> {section_type} (storage: {storage_memory}, execution: {execution_memory})")
    
    return section_mapping

def run_arm_none_eabi_size(elf_file, memory_details):
    #Запуск arm-none-eabi-size
    

    gnu_toolchain_path = sys.argv[5]
    
    try:
        if memory_details:
            print_info("\nДетальная информация о памяти:")
            result = subprocess.run([gnu_toolchain_path, "-A", elf_file], 
                                  capture_output=True, text=True, check=True)
            print(result.stdout)
        
        result = subprocess.run([gnu_toolchain_path, "-A", elf_file], 
                              capture_output=True, text=True, check=True)
        return result.stdout
        
    except subprocess.CalledProcessError as e:
        print_error(f"Ошибка запуска arm-none-eabi-size: {e}")
        return ""
    except FileNotFoundError:
        print_error(f"Ошибка: arm-none-eabi-size.exe не найден по пути: {gnu_toolchain_path}")
        return ""

def parse_section_sizes(size_output):
    #Парсинг размеров секций из вывода arm-none-eabi-size
    section_sizes = {}
    
    print_header("Парсинг размеров секций из memory_config.json:")
    
    for line in size_output.split('\n'):
        line = line.strip()
        if not line:
            continue
            
        # Ищем секции в формате: .name размер ...
        match = re.match(r'^(\.\w+)\s+(\d+)\s+\d+', line)
        if match:
            section_name = match.group(1)
            size = int(match.group(2))
            section_sizes[section_name] = size
            print_success(f"Найдено: {section_name} = {size} bytes")
    
    return section_sizes

def calculate_memory_usage(section_sizes, memory_config):
    #Универсальный расчет использования памяти
    memory_usage = {}
    
    # Инициализируем использование для всех memory_blocks
    for block_name in memory_config['memory_blocks']:
        memory_usage[block_name] = 0
    
    print_header("\nРасчет использования памяти:")
    
    # Обрабатываем все секции
    for section_name, section_size in section_sizes.items():
        if section_name in memory_config['section_mapping']:
            mapping = memory_config['section_mapping'][section_name]
            storage_memory = mapping['storage_memory']
            execution_memory = mapping['execution_memory']
            
            if mapping['mapping_type'] == 'STORED_EXECUTED':
                # Секция хранится в одном месте, выполняется в другом
                if storage_memory in memory_usage:
                    memory_usage[storage_memory] += section_size
                    print_success(f"{storage_memory}->{execution_memory} секция: {section_name} = {section_size} bytes")
                else:
                    print_warning(f"Memory block {storage_memory} не найден для секции {section_name}")
                
                if execution_memory in memory_usage:
                    memory_usage[execution_memory] += section_size
                else:
                    print_warning(f"Memory block {execution_memory} не найден для секции {section_name}")
                    
            else:
                # Секция только в одном месте
                if storage_memory in memory_usage:
                    memory_usage[storage_memory] += section_size
                    print_success(f"{storage_memory} секция: {section_name} = {section_size} bytes")
                else:
                    print_warning(f"Memory block {storage_memory} не найден для секции {section_name}")
        else:
            print_warning(f"Секция {section_name} не найдена в memory_config.json")
    
    print("\nИтоговое использование:")
    for block_name, used in memory_usage.items():
        print(f"  {block_name}: {used} bytes")
    
    return memory_usage

def print_memory_report(memory_usage, memory_config):
    #Универсальный вывод отчета о памяти
    
    #print_header("\n" + "="*85)
    print_header("\nMemory Regions:")
    #print_header("="*85)
    
    # Заголовок таблицы
    header = f"{Colors.BOLD}{'Region':<10} {'Start address':<15} {'End address':<15} {'Size':<10} {'Free':<10} {'Used':<10} {'Usage (%)':<10}{Colors.END}"
    print(header)
    print_header("-"*85)
    
    for block_name, block_info in memory_config['memory_blocks'].items():
        used = memory_usage.get(block_name, 0)
        total = block_info['bytes']
        free = total - used
        
        # Расчет процентов
        percent = round((used / total) * 100, 2) if total > 0 else 0
        
        # Конвертация в человеко-читаемый формат
        total_kb = total / 1024
        free_kb = round(free / 1024, 2)
        used_kb = round(used / 1024, 2)
        
        # Расчет конечных адресов
        start_addr = block_info['origin']
        start_int = int(start_addr, 16)
        end_int = start_int + total
        end_addr = f"0x{end_int:08X}"
        
        # Цвет строки в зависимости от использования
        if percent >= 90:
            row_color = Colors.RED
        elif percent >= 75:
            row_color = Colors.YELLOW
        else:
            row_color = Colors.WHITE
        
        row = f"{row_color}{block_name + ':':<10} {start_addr:<15} {end_addr:<15} {f'{total_kb:.0f} KB':<10} {f'{free_kb} KB':<10} {f'{used_kb} KB':<10} {f'{percent}%':<10}{Colors.END}"
        print(row)

def print_additional_info(memory_usage, memory_config):
    #Вывод дополнительной информации
    print_header("\nБолее детальная информация:")
    
    for block_name, block_info in memory_config['memory_blocks'].items():
        used = memory_usage.get(block_name, 0)
        total = block_info['bytes']
        percent = round((used / total) * 100, 2) if total > 0 else 0
        
        # Цвет в зависимости от уровня использования
        if percent >= 90:
            color = Colors.RED
        elif percent >= 75:
            color = Colors.YELLOW
        else:
            color = Colors.GREEN
            
        print(f"  {block_name}: {color}{used}/{total} bytes использовано ({percent}%){Colors.END}")

def main():
    if len(sys.argv) < 3:
        print_error("Использование: python Build_Analyzer.py <elf_file> <map_file> [memory_details]")
        print_info("Пример: python Build_Analyzer.py project.elf project.map")
        print_info("Пример: python Build_Analyzer.py project.elf project.map true")
        return
    
    elf_file = sys.argv[1]
    map_file = sys.argv[2]
    json_config_path = sys.argv[3]
    memory_details = sys.argv[4]
    
    print_header("Build Analyzer v1.2 от 09.11.2025")
    print_header("Автор: Волков Олег")
    print_header("=" * 85)
    
    analyze_elf_file(elf_file, map_file, json_config_path, memory_details)

if __name__ == "__main__":
    main()