#   ld analyzer v 1.1 (Скрипт еще сырой. Пытаюсь сделать универсальным для ARM и RISC-V. Большую часть писал Deep Seek)
#   Автор: Волков Олег
#   Дата создания скрипта: 12.11.2025
#   GitHub: https://github.com/Solderingironspb
#   Группа Вконтакте: https://vk.com/solderingiron.stm32
#   YouTube: https://www.youtube.com/channel/UCzZKTNVpcMSALU57G1THoVw
#   RuTube: https://rutube.ru/channel/36234184/
#   Яндекс Дзен: https://dzen.ru/id/622208eed2eb4c6d0cd16749

import re
import sys
import json

def format_hex_address(addr_str):
    #Форматирует адрес в виде 8-значного шестнадцатеричного числа
    try:
        # Если адрес уже в hex формате
        if addr_str.startswith('0x') or addr_str.startswith('0X'):
            addr = int(addr_str, 16)
        else:
            addr = int(addr_str)
        
        # Форматируем как 8-значное hex число с ведущими нулями
        return f"0x{addr:08X}"
    except (ValueError, TypeError):
        return addr_str

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

def analyze_linker_script(file_path, output_format="text"):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        if output_format == "json":
            return {"error": f"File {file_path} not found"}
        print(f"Error: File {file_path} not found")
        return None
    except Exception as e:
        if output_format == "json":
            return {"error": f"File read error: {e}"}
        print(f"File read error: {e}")
        return None

    # ПАРСИНГ ПАМЯТИ
    memory_blocks = {}
    memory_match = re.search(r'MEMORY\s*\{([^}]+)\}', content, re.DOTALL)
    if memory_match:
        memory_section = memory_match.group(1)
        
        # Удаляем закомментированные блоки
        memory_clean = re.sub(r'/\*.*?\*/', '', memory_section, flags=re.DOTALL)
        
        memory_lines = memory_clean.split('\n')
        
        for line in memory_lines:
            line = line.strip()
            if not line:
                continue
                
            match = re.search(r'(\w+)\s*\(([^)]+)\)\s*:\s*ORIGIN\s*=\s*(0x[0-9A-Fa-f]+),\s*LENGTH\s*=\s*(\d+[KkMm]?)', line)
            if match:
                name = match.group(1)
                attributes = match.group(2)
                origin = format_hex_address(match.group(3))  # Форматируем адрес
                length = match.group(4)
                
                if 'rx' in attributes:
                    mem_type = 'FLASH'
                elif 'xrw' in attributes:
                    mem_type = 'RAM'
                else:
                    mem_type = 'OTHER'
                
                memory_blocks[name] = {
                    'origin': origin,
                    'length': length,
                    'bytes': parse_memory_size(length),
                    'attributes': attributes,
                    'type': mem_type
                }

    if output_format == "text":
        print(f"File analysis: {file_path}")
        print("=" * 80)
        print("Memory blocks:")
        for name, info in sorted(memory_blocks.items()):
            print(f"  {name}: ORIGIN={info['origin']}, LENGTH={info['length']} ({info['type']})")
        print()

    # ПАРСИНГ СЕКЦИЙ
    sections = []
    
    # Находим блок SECTIONS
    sections_match = re.search(r'SECTIONS\s*\{([^}]*\})', content, re.DOTALL)
    if not sections_match:
        if output_format == "text":
            print("SECTIONS block not found!")
        return None
        
    sections_content = sections_match.group(1)
    
    # Ищем ВСЕ секции с разными паттернами
    patterns = [
        # Паттерн для секций с AT> (многострочные)
        r'\.(\w+)\s*:\s*\{[^}]+\}\s*>(\w+)\s+AT>\s*(\w+)',
        # Паттерн для простых секций (многострочные)  
        r'\.(\w+)\s*:\s*\{[^}]+\}\s*>(\w+)',
        # Паттерн для однострочных секций
        r'\.(\w+)\s*:\s*\{[^\}]+\}\s*>(\w+)(?:\s+AT>\s*(\w+))?',
    ]
    
    for pattern in patterns:
        matches = re.finditer(pattern, sections_content, re.DOTALL)
        for match in matches:
            section_name = f".{match.group(1)}"
            
            # Пропускаем дубликаты
            if any(s['name'] == section_name for s in sections):
                continue
            
            # Определяем параметры в зависимости от количества групп
            if len(match.groups()) == 3 and match.group(3):
                # С AT>
                location = match.group(2)
                load_memory = match.group(3)
            else:
                # Без AT>
                location = match.group(2)
                load_memory = location
            
            # Проверяем, что блоки памяти существуют
            if location not in memory_blocks:
                continue
                
            # Заменяем символ → на -> для совместимости
            if load_memory != location:
                section_type = f"{load_memory} -> {location}"
                description = f"Stored in {load_memory}, executed in {location}"
            else:
                section_type = location
                description = f"Only in {location}"
            
            sections.append({
                'name': section_name,
                'location': location,
                'load_memory': load_memory,
                'type': section_type,
                'description': description,
                'memory_type': memory_blocks[location]['type']
            })

    # Дополнительный поиск для специфических секций
    common_sections = [
        (r'\.isr_vector\s*:\s*\{[^}]+\}\s*>FLASH', '.isr_vector', 'FLASH', 'FLASH'),
        (r'\.text\s*:\s*\{[^}]+\}\s*>FLASH', '.text', 'FLASH', 'FLASH'),
        (r'\.rodata\s*:\s*\{[^}]+\}\s*>FLASH', '.rodata', 'FLASH', 'FLASH'),
        (r'\.ARM\.extab\s*:\s*\{[^}]+\}\s*>FLASH', '.ARM.extab', 'FLASH', 'FLASH'),
        (r'\.ARM\s*:\s*\{[^}]+\}\s*>FLASH', '.ARM', 'FLASH', 'FLASH'),
        (r'\.preinit_array\s*:\s*\{[^}]+\}\s*>FLASH', '.preinit_array', 'FLASH', 'FLASH'),
        (r'\.init_array\s*:\s*\{[^}]+\}\s*>FLASH', '.init_array', 'FLASH', 'FLASH'),
        (r'\.fini_array\s*:\s*\{[^}]+\}\s*>FLASH', '.fini_array', 'FLASH', 'FLASH'),
        (r'\.data\s*:\s*\{[^}]+\}\s*>RAM\s+AT>\s*FLASH', '.data', 'RAM', 'FLASH'),
        (r'\.ccmram\s*:\s*\{[^}]+\}\s*>CCMRAM\s+AT>\s*FLASH', '.ccmram', 'CCMRAM', 'FLASH'),
        (r'\.bss\s*:\s*\{[^}]+\}\s*>RAM', '.bss', 'RAM', 'RAM'),
        (r'\._user_heap_stack\s*:\s*\{[^}]+\}\s*>RAM', '._user_heap_stack', 'RAM', 'RAM'),
        # RISC-V секции
        (r'\.init\s*:\s*\{[^}]+\}\s*>FLASH', '.init', 'FLASH', 'FLASH'),
        (r'\.vector\s*:\s*\{[^}]+\}\s*>FLASH', '.vector', 'FLASH', 'FLASH'),
        (r'\.fini\s*:\s*\{[^}]+\}\s*>FLASH', '.fini', 'FLASH', 'FLASH'),
        (r'\.ctors\s*:\s*\{[^}]+\}\s*>FLASH', '.ctors', 'FLASH', 'FLASH'),
        (r'\.dtors\s*:\s*\{[^}]+\}\s*>FLASH', '.dtors', 'FLASH', 'FLASH'),
        (r'\.dlalign\s*:\s*\{[^}]+\}\s*>FLASH', '.dlalign', 'FLASH', 'FLASH'),
        (r'\.dalign\s*:\s*\{[^}]+\}\s*>RAM', '.dalign', 'RAM', 'FLASH'),
        (r'\.stack\s*:\s*\{[^}]+\}\s*>RAM', '.stack', 'RAM', 'RAM'),
        (r'\.highcodelalign\s*:\s*\{[^}]+\}\s*>FLASH\s+AT>\s*FLASH', '.highcodelalign', 'FLASH', 'FLASH'),
        (r'\.highcode\s*:\s*\{[^}]+\}\s*>RAM\s+AT>\s*FLASH', '.highcode', 'RAM', 'FLASH'),
        (r'\.stack\s*ORIGIN\(RAM\)\s*\+\s*LENGTH\(RAM\)\s*-\s*__stack_size\s*:\s*\{[^}]+\}\s*>RAM', '.stack', 'RAM', 'RAM'),
    ]

    for pattern, section_name, location, load_memory in common_sections:
        if not any(s['name'] == section_name for s in sections):
            if re.search(pattern, content, re.DOTALL) and location in memory_blocks:
                if location != load_memory:
                    section_type = f"{load_memory} -> {location}"
                    description = f"Stored in {load_memory}, executed in {location}"
                else:
                    section_type = location
                    description = f"Only in {location}"
                
                sections.append({
                    'name': section_name,
                    'location': location,
                    'load_memory': load_memory,
                    'type': section_type,
                    'description': description,
                    'memory_type': memory_blocks[location]['type']
                })

    # Удаляем дубликаты и сортируем
    seen = set()
    unique_sections = []
    for section in sections:
        if section['name'] not in seen:
            unique_sections.append(section)
            seen.add(section['name'])
    sections = sorted(unique_sections, key=lambda x: x['name'])

    # ПОДГОТОВКА РЕЗУЛЬТАТОВ
    if output_format == "json":
        result = {
            "memory_blocks": memory_blocks,
            "sections": sections,
            "summary": {
                "total_memory_blocks": len(memory_blocks),
                "total_sections": len(sections),
                "at_sections": len([s for s in sections if '->' in s['type']])
            }
        }
        return result

    # ТЕКСТОВЫЙ ВЫВОД
    if not sections:
        print("Sections not found!")
        return None

    print("SECTION DISTRIBUTION:")
    print()
    
    # Группируем по типам
    grouped = {}
    for section in sections:
        if section['type'] not in grouped:
            grouped[section['type']] = []
        grouped[section['type']].append(section)
    
    # Выводим сгруппированные секции
    for section_type, section_list in sorted(grouped.items()):
        print(f"{section_type}:")
        for section in section_list:
            print(f"  {section['name']}")
            print(f"    {section['description']}")
        print()

    # СТАТИСТИКА
    print("MEMORY TYPE STATISTICS:")
    
    memory_stats = {}
    for mem_name in memory_blocks:
        memory_stats[mem_name] = {
            'type': memory_blocks[mem_name]['type'],
            'sections': []
        }

    for section in sections:
        if '->' in section['type']:
            parts = section['type'].split(' -> ')
            if len(parts) == 2:
                load_mem, exec_mem = parts
                if load_mem in memory_stats:
                    memory_stats[load_mem]['sections'].append(f"{section['name']} (stored)")
                if exec_mem in memory_stats:
                    memory_stats[exec_mem]['sections'].append(f"{section['name']} (executed)")
        else:
            if section['location'] in memory_stats:
                memory_stats[section['location']]['sections'].append(section['name'])

    for mem_name, stats in sorted(memory_stats.items()):
        print(f"  {mem_name} ({stats['type']}): {len(stats['sections'])} sections")
        for section in stats['sections']:
            print(f"    - {section}")
    print()

    # Общая сводка
    print("SUMMARY:")
    print(f"  Total memory blocks: {len(memory_blocks)}")
    print(f"  Total sections: {len(sections)}")
    
    at_sections = [s for s in sections if '->' in s['type']]
    print(f"  Sections with distribution (AT>): {len(at_sections)}")
    
    memory_types = {}
    for block in memory_blocks.values():
        mem_type = block['type']
        memory_types[mem_type] = memory_types.get(mem_type, 0) + 1
    
    for mem_type, count in memory_types.items():
        print(f"  Blocks of type {mem_type}: {count}")
    
    return None

def main():
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
        output_format = sys.argv[2] if len(sys.argv) > 2 else "text"
    else:
        print("Usage: python ld_analyzer.py <ld_file_path> [json|text]")
        print("Example: python ld_analyzer.py STM32F103C8TX_FLASH.ld")
        print("Example: python ld_analyzer.py STM32F103C8TX_FLASH.ld json")
        return
    
    if output_format == "json":
        result = analyze_linker_script(file_path, "json")
        if result:
            # Устанавливаем UTF-8 кодировку для вывода
            if sys.platform == "win32":
                sys.stdout.reconfigure(encoding='utf-8')
            print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        analyze_linker_script(file_path, "text")

if __name__ == "__main__":
    main()