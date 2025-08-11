#!/bin/bash

# Mac Cleaner Script - Эффективный скрипт для очистки Mac
# Автор: Cascade AI
# Версия: 1.0

# Установка цветов для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Функция для вывода заголовков
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Функция для вывода успешных сообщений
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Функция для вывода предупреждений
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Функция для очистки с выводом размера до и после
clean_with_size() {
    local path="$1"
    local description="$2"
    
    if [ -d "$path" ]; then
        local before=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
        echo -e "${YELLOW}Очистка $description (сейчас: $before)...${NC}"
        rm -rf "$path"/* 2>/dev/null
        local after=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
        print_success "$description очищено! (было: $before, стало: $after)"
    else
        print_warning "$description не найдено"
    fi
}

# Начало скрипта
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}       MAC CLEANER SCRIPT 1.0         ${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "Начинаем очистку Mac...\n"

# Очистка корзины
print_header "Очистка корзины"
rm -rf ~/.Trash/* 2>/dev/null
print_success "Корзина очищена!"

# Очистка кэша браузеров
print_header "Очистка кэша Chrome"
clean_with_size ~/Library/Caches/Google/Chrome "Кэш Chrome"
clean_with_size ~/Library/Application\ Support/Google/Chrome/Default/Cache "Дополнительный кэш Chrome"

print_header "Очистка кэша Safari"
clean_with_size ~/Library/Caches/com.apple.Safari "Кэш Safari"
clean_with_size ~/Library/Safari/LocalStorage "LocalStorage Safari"

print_header "Очистка кэша Firefox"
clean_with_size ~/Library/Caches/Mozilla/Firefox "Кэш Firefox"

# Очистка системного кэша
print_header "Очистка системного кэша"
sudo rm -rf /Library/Caches/* 2>/dev/null
clean_with_size ~/Library/Caches "Пользовательский кэш"

# Очистка логов
print_header "Очистка логов"
sudo rm -rf /private/var/log/asl/*.asl 2>/dev/null
clean_with_size /Library/Logs "Системные логи"
clean_with_size ~/Library/Logs "Пользовательские логи"

# Очистка временных файлов
print_header "Очистка временных файлов"
clean_with_size /private/var/tmp "Временные файлы"
clean_with_size /tmp "Общие временные файлы"

# Очистка загрузок iTunes
print_header "Очистка кэша iTunes"
clean_with_size ~/Library/Caches/com.apple.iTunes "Кэш iTunes"

# Очистка файлов обновлений macOS
print_header "Очистка установщиков macOS"
sudo rm -rf /Library/Updates/* 2>/dev/null
print_success "Установщики macOS удалены"

# Очистка кэша App Store
print_header "Очистка кэша App Store"
clean_with_size ~/Library/Caches/com.apple.appstore "Кэш App Store"

# Очистка снимков iOS устройств
print_header "Очистка снимков iOS"
clean_with_size ~/Library/Application\ Support/MobileSync/Backup "iOS бэкапы"

# Очистка кэша Xcode
print_header "Очистка кэша Xcode (если установлен)"
clean_with_size ~/Library/Developer/Xcode/DerivedData "Xcode DerivedData"
clean_with_size ~/Library/Developer/Xcode/Archives "Xcode Archives"

# Очистка Docker (если установлен)
print_header "Очистка Docker (если установлен)"
docker system prune -af 2>/dev/null
if [ $? -eq 0 ]; then
    print_success "Docker очищен"
else
    print_warning "Docker не найден или не запущен"
fi

# Очистка кэша npm (если установлен)
print_header "Очистка кэша npm (если установлен)"
npm cache clean --force 2>/dev/null
if [ $? -eq 0 ]; then
    print_success "Кэш npm очищен"
else
    print_warning "npm не найден"
fi

# Очистка кэша Homebrew (если установлен)
print_header "Очистка кэша Homebrew (если установлен)"
brew cleanup 2>/dev/null
if [ $? -eq 0 ]; then
    print_success "Homebrew очищен"
else
    print_warning "Homebrew не найден"
fi

# Завершение
echo -e "\n${GREEN}======================================${NC}"
echo -e "${GREEN}       ОЧИСТКА ЗАВЕРШЕНА!             ${NC}"
echo -e "${GREEN}======================================${NC}"
echo -e "\n${BLUE}Ваш Mac теперь чище и должен работать быстрее!${NC}"
echo -e "${YELLOW}Примечание: Некоторые операции требуют sudo, если они не выполнены, запустите скрипт с sudo${NC}\n"
