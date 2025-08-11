#!/bin/bash

# Mac Cleaner Pro - Расширенный скрипт для глубокой очистки Mac
# Автор: Cascade AI
# Версия: 2.0

# Установка цветов для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Начальный размер диска
DISK_SPACE_BEFORE=$(df -h / | grep / | awk '{print $4}')

# Счетчик для подсчета освобожденного места
TOTAL_SPACE_CLEARED=0

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
        local before_bytes=$(du -sk "$path" 2>/dev/null | awk '{print $1}')
        local before=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
        echo -e "${YELLOW}Очистка $description (сейчас: $before)...${NC}"
        
        # Проверка на права доступа
        if rm -rf "$path"/* 2>/dev/null; then
            echo -ne ""
        else
            echo -e "${YELLOW}Требуются права администратора для очистки $description${NC}"
            sudo rm -rf "$path"/* 2>/dev/null
        fi
        
        local after_bytes=$(du -sk "$path" 2>/dev/null | awk '{print $1}')
        local after=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
        local freed=$((before_bytes - after_bytes))
        TOTAL_SPACE_CLEARED=$((TOTAL_SPACE_CLEARED + freed))
        
        # Конвертация в удобочитаемый формат
        local freed_readable
        if [ $freed -gt 1048576 ]; then  # Больше 1GB (1048576KB)
            freed_readable=$(echo "scale=2; $freed/1048576" | bc)
            freed_readable="${freed_readable}GB"
        elif [ $freed -gt 1024 ]; then  # Больше 1MB
            freed_readable=$(echo "scale=2; $freed/1024" | bc)
            freed_readable="${freed_readable}MB"
        else
            freed_readable="${freed}KB"
        fi
        
        if [ $freed -gt 0 ]; then
            print_success "$description очищено! (Освобождено: $freed_readable)"
        else
            print_success "$description уже было чистым"
        fi
    else
        print_warning "$description не найдено"
    fi
}

# Начало скрипта
echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}       MAC CLEANER PRO v2.0                 ${NC}"
echo -e "${CYAN}      РАСШИРЕННАЯ ВЕРСИЯ                    ${NC}"
echo -e "${CYAN}=============================================${NC}"
echo -e "Начинаем глубокую очистку Mac...${YELLOW}Начальное свободное место: $DISK_SPACE_BEFORE${NC}\n"

# БЛОК 1: ОЧИСТКА КОРЗИНЫ И ЗАГРУЗОК
print_header "БЛОК 1: ОЧИСТКА КОРЗИНЫ И ЗАГРУЗОК"

# Очистка корзины
print_header "Очистка корзины"
rm -rf ~/.Trash/* 2>/dev/null
sudo rm -rf /Volumes/*/.Trashes/* 2>/dev/null
print_success "Корзина очищена!"

# Очистка папки Downloads (опционально)
print_header "Очистка старых загрузок (старше 30 дней)"
find ~/Downloads -type f -mtime +30 -exec rm -rf {} \; 2>/dev/null
print_success "Старые загруженные файлы очищены"

# БЛОК 2: ОЧИСТКА КЭША БРАУЗЕРОВ
print_header "БЛОК 2: ОЧИСТКА КЭША БРАУЗЕРОВ"

# Chrome
print_header "Очистка кэша Chrome"
clean_with_size ~/Library/Caches/Google/Chrome "Кэш Chrome"
clean_with_size ~/Library/Application\ Support/Google/Chrome/Default/Cache "Дополнительный кэш Chrome"
clean_with_size ~/Library/Application\ Support/Google/Chrome/Default/Service\ Worker "Chrome Service Workers"
clean_with_size ~/Library/Application\ Support/Google/Chrome/Default/Storage/ext "Chrome расширения"
clean_with_size ~/Library/Application\ Support/Google/Chrome/ShaderCache "Chrome Shader Cache"

# Safari
print_header "Очистка кэша Safari"
clean_with_size ~/Library/Caches/com.apple.Safari "Кэш Safari"
clean_with_size ~/Library/Safari/LocalStorage "LocalStorage Safari"
clean_with_size ~/Library/Safari/Databases "Базы данных Safari"
clean_with_size ~/Library/Safari/ServiceWorkers "Service Workers Safari"
clean_with_size ~/Library/Containers/com.apple.Safari/Data/Library/Caches "Контейнеры Safari"

# Firefox
print_header "Очистка кэша Firefox"
clean_with_size ~/Library/Caches/Mozilla/Firefox "Кэш Firefox"
clean_with_size ~/Library/Application\ Support/Firefox/Profiles/*/cache2 "Кэш Firefox"
clean_with_size ~/Library/Application\ Support/Firefox/Profiles/*/startupCache "Startup кэш Firefox"

# Яндекс.Браузер
print_header "Очистка кэша Яндекс.Браузера"
clean_with_size ~/Library/Caches/YandexBrowser "Кэш Яндекс.Браузера"

# Edge
print_header "Очистка кэша Microsoft Edge"
clean_with_size ~/Library/Caches/Microsoft\ Edge "Кэш Edge"
clean_with_size ~/Library/Application\ Support/Microsoft\ Edge/Default/Cache "Дополнительный кэш Edge"

# Браузер Arc
print_header "Очистка кэша браузера Arc"
clean_with_size ~/Library/Caches/company.thebrowser.Browser "Кэш Arc"
clean_with_size ~/Library/Application\ Support/Arc/User\ Data/Default/Cache "Дополнительный кэш Arc"

# Brave
print_header "Очистка кэша Brave"
clean_with_size ~/Library/Caches/BraveSoftware "Кэш Brave"

# БЛОК 3: ОЧИСТКА СИСТЕМНОГО КЭША
print_header "БЛОК 3: ОЧИСТКА СИСТЕМНОГО КЭША"

# Системный кэш
print_header "Очистка системного кэша"
sudo rm -rf /Library/Caches/* 2>/dev/null
clean_with_size ~/Library/Caches "Пользовательский кэш"
clean_with_size /private/var/folders "Временные системные папки"
sudo rm -rf /Users/Shared/* 2>/dev/null

# Очистка логов
print_header "Очистка логов"
sudo rm -rf /private/var/log/asl/*.asl 2>/dev/null
clean_with_size /Library/Logs "Системные логи"
clean_with_size ~/Library/Logs "Пользовательские логи"
sudo rm -rf /var/log/DiagnosticMessages/* 2>/dev/null

# Очистка временных файлов
print_header "Очистка временных файлов"
clean_with_size /private/var/tmp "Временные файлы"
clean_with_size /tmp "Общие временные файлы"

# Очистка спулера печати
print_header "Очистка спулера печати"
sudo rm -rf /var/spool/cups/tmp/* 2>/dev/null
sudo rm -rf /var/spool/cups/cache/job.cache* 2>/dev/null
print_success "Спулер печати очищен"

# БЛОК 4: ОЧИСТКА ПРИЛОЖЕНИЙ APPLE
print_header "БЛОК 4: ОЧИСТКА ПРИЛОЖЕНИЙ APPLE"

# Очистка Apple Mail
print_header "Очистка Apple Mail"
clean_with_size ~/Library/Containers/com.apple.mail/Data/Library/Caches "Кэш Mail"
clean_with_size ~/Library/Mail/V*/MailData/Envelope\ Index "Индекс Mail"

# Очистка Messages
print_header "Очистка Messages"
clean_with_size ~/Library/Messages/Attachments "Вложения Messages"
clean_with_size ~/Library/Messages/Archives "Архивы Messages"

# Очистка iTunes
print_header "Очистка кэша iTunes/Music"
clean_with_size ~/Library/Caches/com.apple.itunes "Кэш iTunes"
clean_with_size ~/Library/Caches/com.apple.Music "Кэш Music"

# Очистка файлов обновлений macOS
print_header "Очистка установщиков macOS"
sudo rm -rf /Library/Updates/* 2>/dev/null
clean_with_size /Library/Application\ Support/CrashReporter "Отчеты о сбоях"
print_success "Установщики macOS удалены"

# Очистка кэша App Store
print_header "Очистка кэша App Store"
clean_with_size ~/Library/Caches/com.apple.appstore "Кэш App Store"

# Очистка снимков iOS устройств
print_header "Очистка снимков iOS"
clean_with_size ~/Library/Application\ Support/MobileSync/Backup "iOS бэкапы"

# БЛОК 5: ИНСТРУМЕНТЫ РАЗРАБОТЧИКА
print_header "БЛОК 5: ИНСТРУМЕНТЫ РАЗРАБОТЧИКА"

# Очистка кэша Xcode
print_header "Очистка кэша Xcode (если установлен)"
clean_with_size ~/Library/Developer/Xcode/DerivedData "Xcode DerivedData"
clean_with_size ~/Library/Developer/Xcode/Archives "Xcode Archives"
clean_with_size ~/Library/Developer/Xcode/iOS\ DeviceSupport "iOS DeviceSupport"
clean_with_size ~/Library/Developer/CoreSimulator/Caches "Кэш симулятора"

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
brew cleanup -s 2>/dev/null
if [ $? -eq 0 ]; then
    print_success "Homebrew очищен"
else
    print_warning "Homebrew не найден"
fi

# Очистка кэша pip (если установлен)
print_header "Очистка кэша pip (если установлен)"
pip cache purge 2>/dev/null
if [ $? -eq 0 ]; then
    print_success "Кэш pip очищен"
else
    print_warning "pip не найден или не распознан"
fi

# Очистка кэша Gradle (если установлен)
print_header "Очистка кэша Gradle (если установлен)"
clean_with_size ~/.gradle/caches "Кэш Gradle"

# Очистка кэша Maven (если установлен)
print_header "Очистка кэша Maven (если установлен)"
clean_with_size ~/.m2/repository "Кэш Maven"

# Очистка кэша Yarn (если установлен)
print_header "Очистка кэша Yarn (если установлен)"
yarn cache clean 2>/dev/null
if [ $? -eq 0 ]; then
    print_success "Кэш Yarn очищен"
else
    print_warning "Yarn не найден"
fi

# БЛОК 6: ОЧИСТКА ПРИЛОЖЕНИЙ
print_header "БЛОК 6: ОЧИСТКА ПРИЛОЖЕНИЙ"

# Slack
print_header "Очистка кэша Slack"
clean_with_size ~/Library/Application\ Support/Slack/Cache "Кэш Slack"
clean_with_size ~/Library/Application\ Support/Slack/Service\ Worker/CacheStorage "Кэш сервис-воркеров Slack"

# VS Code
print_header "Очистка кэша VS Code"
clean_with_size ~/Library/Application\ Support/Code/Cache "Кэш VS Code"
clean_with_size ~/Library/Application\ Support/Code/CachedData "Кэшированные данные VS Code"
clean_with_size ~/Library/Application\ Support/Code/User/workspaceStorage "Хранилище рабочих областей VS Code"

# Telegram
print_header "Очистка кэша Telegram"
clean_with_size ~/Library/Group\ Containers/*.ru.keepcoder.Telegram/stickers "Стикеры Telegram"
clean_with_size ~/Library/Group\ Containers/*.ru.keepcoder.Telegram/lottie "Анимации Telegram"
clean_with_size ~/Library/Group\ Containers/*.ru.keepcoder.Telegram/mediacache "Медиа-кэш Telegram"

# Discord
print_header "Очистка кэша Discord"
clean_with_size ~/Library/Application\ Support/discord/Cache "Кэш Discord"

# Spotify
print_header "Очистка кэша Spotify"
clean_with_size ~/Library/Application\ Support/Spotify/PersistentCache "Кэш Spotify"

# Adobe Creative Cloud
print_header "Очистка кэша Adobe"
clean_with_size ~/Library/Application\ Support/Adobe/Common/Media\ Cache\ Files "Кэш медиа Adobe"

# JetBrains IDEs
print_header "Очистка кэша JetBrains"
clean_with_size ~/Library/Caches/JetBrains "Кэш JetBrains"
find ~/Library/Logs/JetBrains -type f -name "*.log" -delete 2>/dev/null

# БЛОК 7: ОЧИСТКА СИСТЕМНОЙ ПАМЯТИ
print_header "БЛОК 7: ОЧИСТКА СИСТЕМНОЙ ПАМЯТИ"

# Очистка DNS кэша
print_header "Очистка DNS кэша"
sudo dscacheutil -flushcache 2>/dev/null
sudo killall -HUP mDNSResponder 2>/dev/null
print_success "DNS кэш очищен"

# Очистка неактивной памяти
print_header "Очистка неактивной памяти"
sudo purge 2>/dev/null
print_success "Неактивная память очищена"

# БЛОК 8: ОПТИМИЗАЦИЯ
print_header "БЛОК 8: ОПТИМИЗАЦИЯ"

# Очистка моментальных снимков Time Machine
print_header "Очистка локальных снимков Time Machine"
tmutil thinlocalsnapshots / 9999999999 2>/dev/null
print_success "Снимки Time Machine оптимизированы"

# Очистка Spotlight индекса (опционально)
print_header "Перестройка индекса Spotlight"
sudo mdutil -E / 2>/dev/null
print_success "Индекс Spotlight перестроен"

# Вычисление конечного размера диска
DISK_SPACE_AFTER=$(df -h / | grep / | awk '{print $4}')

# Конвертация общего освобожденного места в удобочитаемый формат
TOTAL_SPACE_CLEARED_READABLE=""
if [ $TOTAL_SPACE_CLEARED -gt 1048576 ]; then  # Больше 1GB (1048576KB)
    TOTAL_SPACE_CLEARED_READABLE=$(echo "scale=2; $TOTAL_SPACE_CLEARED/1048576" | bc)
    TOTAL_SPACE_CLEARED_READABLE="${TOTAL_SPACE_CLEARED_READABLE} ГБ"
elif [ $TOTAL_SPACE_CLEARED -gt 1024 ]; then  # Больше 1MB
    TOTAL_SPACE_CLEARED_READABLE=$(echo "scale=2; $TOTAL_SPACE_CLEARED/1024" | bc)
    TOTAL_SPACE_CLEARED_READABLE="${TOTAL_SPACE_CLEARED_READABLE} МБ"
else
    TOTAL_SPACE_CLEARED_READABLE="${TOTAL_SPACE_CLEARED} КБ"
fi

# Завершение
echo -e "\n${GREEN}=============================================${NC}"
echo -e "${GREEN}       ГЛУБОКАЯ ОЧИСТКА ЗАВЕРШЕНА!          ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "\n${BLUE}Ваш Mac теперь намного чище и должен работать быстрее!${NC}"
echo -e "\n${YELLOW}Было свободно: $DISK_SPACE_BEFORE${NC}"
echo -e "${GREEN}Сейчас свободно: $DISK_SPACE_AFTER${NC}"
echo -e "${CYAN}Примерно очищено: $TOTAL_SPACE_CLEARED_READABLE${NC}\n"
echo -e "${YELLOW}Примечание: Некоторые операции требуют sudo, если они не выполнены, запустите скрипт с sudo${NC}\n"
