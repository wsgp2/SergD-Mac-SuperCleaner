#!/bin/bash

# Mac Cleaner Pro - Расширенный скрипт для глубокой очистки Mac
# Автор: Cascade AI; улучшения: безопасная работа с sudo, dry-run, логирование, проверки команд
# Версия: 2.1

set -Eeuo pipefail
IFS=$'\n\t'

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Лог в файл + на экран
LOG_FILE="/tmp/mac-cleaner-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

trap 'echo -e "${RED}Ошибка на строке $LINENO${NC}" >&2' ERR

# Опции
IS_DRY_RUN=false
AUTO_YES=false
CLEAN_DOWNLOADS=false
while getopts ":nyD" opt; do
  case $opt in
    n) IS_DRY_RUN=true ;;
    y) AUTO_YES=true ;;
    D) CLEAN_DOWNLOADS=true ;;
    *) ;; # неизвестные флаги игнорируем для обратной совместимости
  esac
done

run() {
  # обертка для dry-run
  if $IS_DRY_RUN; then
    printf "[dry-run]"
    printf " %q" "$@"
    printf "\n"
    return 0
  fi
  eval "$@"
}

confirm() {
  local msg="$1"
  if $AUTO_YES; then
    return 0
  fi
  read -r -p "$msg [y/N]: " reply || true
  [[ ${reply:-N} == "y" || ${reply:-N} == "Y" ]]
}

cmd_exists() { command -v "$1" >/dev/null 2>&1; }

# Корректный домашний каталог пользователя при sudo
if [[ -n "${SUDO_USER-}" && "${SUDO_USER}" != "root" ]]; then
  USER_HOME=$(dscl . -read /Users/"$SUDO_USER" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
  USER_HOME=${USER_HOME:-/Users/$SUDO_USER}
else
  USER_HOME="$HOME"
fi

# Поддержание sudo-сессии активной, если доступен sudo (пропускаем в dry-run)
if ! $IS_DRY_RUN && cmd_exists sudo; then
  sudo -v || true
  { while true; do sleep 50; sudo -n true 2>/dev/null || exit; done } &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill ${SUDO_KEEPALIVE_PID:-0} 2>/dev/null || true' EXIT
fi

# Подсчет освобожденного места
DISK_SPACE_BEFORE=$(df -h / | awk 'NR==2{print $4}')
TOTAL_SPACE_CLEARED=0

print_header() { echo -e "\n${BLUE}=== $1 ===${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }

human_kb() {
  local kb=${1:-0}
  awk -v k="$kb" 'BEGIN{if(k>=1048576) printf "%.2f GB", k/1048576; else if(k>=1024) printf "%.2f MB", k/1024; else printf "%d KB", k}'
}

# Безопасная очистка содержимого директории; поддерживает глобы в шаблоне пути
safe_clean_dir() {
  local path_pattern="$1"; local description="$2"

  # Собираем совпадения по шаблону (nullglob) — только директории
  local matched=()
  while IFS= read -r -d '' p; do
    [[ -d "$p" ]] && matched+=("$p")
  done < <(bash -c 'shopt -s nullglob; for p in '"$path_pattern"'; do printf "%s\0" "$p"; done')

  if [[ ${#matched[@]} -eq 0 ]]; then
    print_warning "$description не найдено ($path_pattern)"
    return 0
  fi

  for dir in "${matched[@]}"; do
    local before_kb after_kb freed_kb before_h
    before_kb=$(du -sk "$dir" 2>/dev/null | awk '{print $1}' || true)
    before_h=$(du -sh "$dir" 2>/dev/null | awk '{print $1}' || true)
    echo -e "${YELLOW}Очистка $description: $dir (сейчас: $before_h)${NC}"

    if $IS_DRY_RUN; then
      echo "[dry-run] find \"$dir\" -mindepth 1 -exec rm -rf {} +"
    else
      if ! find "$dir" -mindepth 1 -exec rm -rf {} + 2>/dev/null; then
        run sudo find "$dir" -mindepth 1 -exec rm -rf {} + 2>/dev/null || true
      fi
    fi

    after_kb=$(du -sk "$dir" 2>/dev/null | awk '{print $1}' || true)
    freed_kb=$(( before_kb - after_kb ))
    (( freed_kb < 0 )) && freed_kb=0
    TOTAL_SPACE_CLEARED=$(( TOTAL_SPACE_CLEARED + freed_kb ))
    print_success "$description очищено (освобождено: $(human_kb "$freed_kb"))"
  done
}

# Безопасное удаление файлов/директорий по шаблону (поддержка глобы, включая файлы)
safe_delete_glob() {
  local path_pattern="$1"; local description="$2"
  local matched=()
  while IFS= read -r -d '' p; do
    matched+=("$p")
  done < <(bash -c 'shopt -s nullglob; for p in '"$path_pattern"'; do printf "%s\0" "$p"; done')

  if [[ ${#matched[@]} -eq 0 ]]; then
    print_warning "$description не найдено ($path_pattern)"
    return 0
  fi

  for item in "${matched[@]}"; do
    echo -e "${YELLOW}Удаление $description: $item${NC}"
    if $IS_DRY_RUN; then
      echo "[dry-run] rm -rf '$item'"
    else
      run rm -rf "$item" 2>/dev/null || run sudo rm -rf "$item" 2>/dev/null || true
    fi
  done
  print_success "$description удалён(ы)"
}

# Баннер
echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}       MAC CLEANER PRO v2.1                 ${NC}"
echo -e "${CYAN}      РАСШИРЕННАЯ ВЕРСИЯ                    ${NC}"
echo -e "${CYAN}=============================================${NC}"
echo -e "Начинаем глубокую очистку Mac...${YELLOW}Начальное свободное место: $DISK_SPACE_BEFORE${NC}\n"
echo -e "Лог-файл: ${CYAN}$LOG_FILE${NC}"

# БЛОК 1: ОЧИСТКА КОРЗИНЫ И ЗАГРУЗОК
print_header "БЛОК 1: ОЧИСТКА КОРЗИНЫ И ЗАГРУЗОК"

# Очистка корзины
print_header "Очистка корзины"
safe_clean_dir "$USER_HOME/.Trash" "Корзина"
run sudo rm -rf /Volumes/*/.Trashes/* 2>/dev/null || true
print_success "Корзина очищена!"

# Очистка папки Downloads (опционально с флагом -D)
if $CLEAN_DOWNLOADS; then
  print_header "Очистка старых загрузок (старше 30 дней)"
  if $IS_DRY_RUN; then
    echo "[dry-run] find '$USER_HOME/Downloads' -type f -mtime +30 -exec rm -rf {} +"
  else
    run bash -c 'find '"$USER_HOME"'/Downloads -type f -mtime +30 -exec rm -rf {} +' 2>/dev/null || true
  fi
  print_success "Старые загруженные файлы очищены"
else
  print_header "Очистка старых загрузок: пропущено (включить флагом -D)"
fi

# БЛОК 2: ОЧИСТКА КЭША БРАУЗЕРОВ
print_header "БЛОК 2: ОЧИСТКА КЭША БРАУЗЕРОВ"

# Chrome
print_header "Очистка кэша Chrome"
safe_clean_dir "$USER_HOME/Library/Caches/Google/Chrome" "Кэш Chrome"
safe_clean_dir "$USER_HOME/Library/Application Support/Google/Chrome/Default/Cache" "Дополнительный кэш Chrome"
safe_clean_dir "$USER_HOME/Library/Application Support/Google/Chrome/Default/Service Worker" "Chrome Service Workers"
safe_clean_dir "$USER_HOME/Library/Application Support/Google/Chrome/Default/Storage/ext" "Chrome расширения"
safe_clean_dir "$USER_HOME/Library/Application Support/Google/Chrome/ShaderCache" "Chrome Shader Cache"

# Safari
print_header "Очистка кэша Safari"
safe_clean_dir "$USER_HOME/Library/Caches/com.apple.Safari" "Кэш Safari"
safe_clean_dir "$USER_HOME/Library/Safari/LocalStorage" "LocalStorage Safari"
safe_clean_dir "$USER_HOME/Library/Safari/Databases" "Базы данных Safari"
safe_clean_dir "$USER_HOME/Library/Safari/ServiceWorkers" "Service Workers Safari"
safe_clean_dir "$USER_HOME/Library/Containers/com.apple.Safari/Data/Library/Caches" "Контейнеры Safari"

# Firefox
print_header "Очистка кэша Firefox"
safe_clean_dir "$USER_HOME/Library/Caches/Mozilla/Firefox" "Кэш Firefox"
safe_clean_dir "$USER_HOME/Library/Application Support/Firefox/Profiles"/*"/cache2" "Кэш Firefox"
safe_clean_dir "$USER_HOME/Library/Application Support/Firefox/Profiles"/*"/startupCache" "Startup кэш Firefox"

# Яндекс.Браузер
print_header "Очистка кэша Яндекс.Браузера"
safe_clean_dir "$USER_HOME/Library/Caches/YandexBrowser" "Кэш Яндекс.Браузера"

# Edge
print_header "Очистка кэша Microsoft Edge"
safe_clean_dir "$USER_HOME/Library/Caches/Microsoft Edge" "Кэш Edge"
safe_clean_dir "$USER_HOME/Library/Application Support/Microsoft Edge/Default/Cache" "Дополнительный кэш Edge"

# Браузер Arc
print_header "Очистка кэша браузера Arc"
safe_clean_dir "$USER_HOME/Library/Caches/company.thebrowser.Browser" "Кэш Arc"
safe_clean_dir "$USER_HOME/Library/Application Support/Arc/User Data/Default/Cache" "Дополнительный кэш Arc"

# Brave
print_header "Очистка кэша Brave"
safe_clean_dir "$USER_HOME/Library/Caches/BraveSoftware" "Кэш Brave"

# БЛОК 3: ОЧИСТКА СИСТЕМНОГО КЭША
print_header "БЛОК 3: ОЧИСТКА СИСТЕМНОГО КЭША"

# Системный кэш
print_header "Очистка системного кэша"
run sudo rm -rf /Library/Caches/* 2>/dev/null || true
safe_clean_dir "$USER_HOME/Library/Caches" "Пользовательский кэш"
safe_clean_dir "/private/var/folders" "Временные системные папки"
run sudo rm -rf /Users/Shared/* 2>/dev/null || true

# Очистка логов
print_header "Очистка логов"
run sudo rm -rf /private/var/log/asl/*.asl 2>/dev/null || true
safe_clean_dir "/Library/Logs" "Системные логи"
safe_clean_dir "$USER_HOME/Library/Logs" "Пользовательские логи"
run sudo rm -rf /var/log/DiagnosticMessages/* 2>/dev/null || true

# Очистка временных файлов
print_header "Очистка временных файлов"
safe_clean_dir "/private/var/tmp" "Временные файлы"
safe_clean_dir "/tmp" "Общие временные файлы"

# Очистка спулера печати
print_header "Очистка спулера печати"
run sudo rm -rf /var/spool/cups/tmp/* 2>/dev/null || true
run sudo rm -rf /var/spool/cups/cache/job.cache* 2>/dev/null || true
print_success "Спулер печати очищен"

# БЛОК 4: ОЧИСТКА ПРИЛОЖЕНИЙ APPLE
print_header "БЛОК 4: ОЧИСТКА ПРИЛОЖЕНИЙ APPLE"

# Очистка Apple Mail
print_header "Очистка Apple Mail"
safe_clean_dir "$USER_HOME/Library/Containers/com.apple.mail/Data/Library/Caches" "Кэш Mail"
safe_clean_dir "$USER_HOME/Library/Mail/"V*"/MailData/Envelope Index" "Индекс Mail"

# Очистка Messages
print_header "Очистка Messages"
safe_clean_dir "$USER_HOME/Library/Messages/Attachments" "Вложения Messages"
safe_clean_dir "$USER_HOME/Library/Messages/Archives" "Архивы Messages"

# Очистка iTunes
print_header "Очистка кэша iTunes/Music"
safe_clean_dir "$USER_HOME/Library/Caches/com.apple.itunes" "Кэш iTunes"
safe_clean_dir "$USER_HOME/Library/Caches/com.apple.Music" "Кэш Music"

# Очистка файлов обновлений macOS
print_header "Очистка установщиков macOS"
run sudo rm -rf /Library/Updates/* 2>/dev/null || true
safe_clean_dir "/Library/Application Support/CrashReporter" "Отчеты о сбоях"
print_success "Установщики macOS удалены"

# Очистка кэша App Store
print_header "Очистка кэша App Store"
safe_clean_dir "$USER_HOME/Library/Caches/com.apple.appstore" "Кэш App Store"

# Очистка снимков iOS устройств
print_header "Очистка снимков iOS"
safe_clean_dir "$USER_HOME/Library/Application Support/MobileSync/Backup" "iOS бэкапы"

# БЛОК 5: ИНСТРУМЕНТЫ РАЗРАБОТЧИКА
print_header "БЛОК 5: ИНСТРУМЕНТЫ РАЗРАБОТЧИКА"

# Очистка кэша Xcode
print_header "Очистка кэша Xcode (если установлен)"
safe_clean_dir "$USER_HOME/Library/Developer/Xcode/DerivedData" "Xcode DerivedData"
safe_clean_dir "$USER_HOME/Library/Developer/Xcode/Archives" "Xcode Archives"
safe_clean_dir "$USER_HOME/Library/Developer/Xcode/iOS DeviceSupport" "iOS DeviceSupport"
safe_clean_dir "$USER_HOME/Library/Developer/CoreSimulator/Caches" "Кэш симулятора"

# Очистка Docker (если установлен)
print_header "Очистка Docker (если установлен)"
if cmd_exists docker; then
  run docker system prune -af 2>/dev/null && print_success "Docker очищен" || print_warning "Docker не запущен"
else
  print_warning "Docker не найден"
fi

# Очистка кэша npm (если установлен)
print_header "Очистка кэша npm (если установлен)"
if cmd_exists npm; then
  run npm cache clean --force 2>/dev/null && print_success "Кэш npm очищен" || print_warning "Не удалось очистить кэш npm"
else
  print_warning "npm не найден"
fi

# Очистка кэша Homebrew (если установлен)
print_header "Очистка кэша Homebrew (если установлен)"
if cmd_exists brew; then
  run brew cleanup -s 2>/dev/null && print_success "Homebrew очищен" || print_warning "Не удалось очистить Homebrew"
else
  print_warning "Homebrew не найден"
fi

# Очистка кэша pip (если установлен)
print_header "Очистка кэша pip (если установлен)"
if cmd_exists pip; then
  run pip cache purge 2>/dev/null && print_success "Кэш pip очищен" || print_warning "Не удалось очистить кэш pip"
elif cmd_exists pip3; then
  run pip3 cache purge 2>/dev/null && print_success "Кэш pip3 очищен" || print_warning "Не удалось очистить кэш pip3"
else
  print_warning "pip не найден"
fi

# Очистка кэша Gradle (если установлен)
print_header "Очистка кэша Gradle (если установлен)"
safe_clean_dir "$USER_HOME/.gradle/caches" "Кэш Gradle"

# Очистка кэша Maven (если установлен)
print_header "Очистка кэша Maven (если установлен)"
safe_clean_dir "$USER_HOME/.m2/repository" "Кэш Maven"

# Очистка кэша Yarn (если установлен)
print_header "Очистка кэша Yarn (если установлен)"
if cmd_exists yarn; then
  run yarn cache clean 2>/dev/null && print_success "Кэш Yarn очищен" || print_warning "Не удалось очистить кэш Yarn"
else
  print_warning "Yarn не найден"
fi

# БЛОК 6: ОЧИСТКА ПРИЛОЖЕНИЙ
print_header "БЛОК 6: ОЧИСТКА ПРИЛОЖЕНИЙ"

# Slack
print_header "Очистка кэша Slack"
safe_clean_dir "$USER_HOME/Library/Application Support/Slack/Cache" "Кэш Slack"
safe_clean_dir "$USER_HOME/Library/Application Support/Slack/Service Worker/CacheStorage" "Кэш сервис-воркеров Slack"

# VS Code
print_header "Очистка кэша VS Code"
safe_clean_dir "$USER_HOME/Library/Application Support/Code/Cache" "Кэш VS Code"
safe_clean_dir "$USER_HOME/Library/Application Support/Code/CachedData" "Кэшированные данные VS Code"
safe_clean_dir "$USER_HOME/Library/Application Support/Code/User/workspaceStorage" "Хранилище рабочих областей VS Code"

# Telegram
print_header "Очистка кэша Telegram"
safe_clean_dir "$USER_HOME/Library/Group Containers/"*.ru.keepcoder.Telegram"/stickers" "Стикеры Telegram"
safe_clean_dir "$USER_HOME/Library/Group Containers/"*.ru.keepcoder.Telegram"/lottie" "Анимации Telegram"
safe_clean_dir "$USER_HOME/Library/Group Containers/"*.ru.keepcoder.Telegram"/mediacache" "Медиа-кэш Telegram"

# Discord
print_header "Очистка кэша Discord"
safe_clean_dir "$USER_HOME/Library/Application Support/discord/Cache" "Кэш Discord"

# Spotify
print_header "Очистка кэша Spotify"
safe_clean_dir "$USER_HOME/Library/Application Support/Spotify/PersistentCache" "Кэш Spotify"

# Adobe Creative Cloud
print_header "Очистка кэша Adobe"
safe_clean_dir "$USER_HOME/Library/Application Support/Adobe/Common/Media Cache Files" "Кэш медиа Adobe"

# JetBrains IDEs
print_header "Очистка кэша JetBrains"
safe_clean_dir "$USER_HOME/Library/Caches/JetBrains" "Кэш JetBrains"
if $IS_DRY_RUN; then
  echo "[dry-run] find '$USER_HOME/Library/Logs/JetBrains' -type f -name '*.log' -delete"
else
  run bash -c 'find '"$USER_HOME"'/Library/Logs/JetBrains -type f -name "*.log" -delete' 2>/dev/null || true
fi

# БЛОК 7: ОЧИСТКА СИСТЕМНОЙ ПАМЯТИ
print_header "БЛОК 7: ОЧИСТКА СИСТЕМНОЙ ПАМЯТИ"

# Очистка DNS кэша
print_header "Очистка DNS кэша"
if cmd_exists dscacheutil && cmd_exists sudo; then
  run sudo dscacheutil -flushcache 2>/dev/null || true
fi
if cmd_exists killall && cmd_exists sudo; then
  run sudo killall -HUP mDNSResponder 2>/dev/null || true
fi
print_success "DNS кэш очищен"

# Очистка неактивной памяти
print_header "Очистка неактивной памяти"
if cmd_exists purge && cmd_exists sudo; then
  run sudo purge 2>/dev/null || true
else
  print_warning "Команда purge недоступна"
fi
print_success "Неактивная память очищена"

# БЛОК 8: ОПТИМИЗАЦИЯ
print_header "БЛОК 8: ОПТИМИЗАЦИЯ"

# Очистка моментальных снимков Time Machine
print_header "Очистка локальных снимков Time Machine"
if cmd_exists tmutil; then
  run tmutil thinlocalsnapshots / 9999999999 2>/dev/null || true
  print_success "Снимки Time Machine оптимизированы"
else
  print_warning "tmutil не найден"
fi

# Очистка Spotlight индекса (опционально)
print_header "Перестройка индекса Spotlight"
if cmd_exists mdutil && cmd_exists sudo; then
  run sudo mdutil -E / 2>/dev/null || true
  print_success "Индекс Spotlight перестроен"
else
  print_warning "mdutil недоступен"
fi

# Вычисление конечного размера диска
DISK_SPACE_AFTER=$(df -h / | awk 'NR==2{print $4}')

# Конвертация общего освобожденного места в удобочитаемый формат
TOTAL_SPACE_CLEARED_READABLE=$(human_kb "$TOTAL_SPACE_CLEARED")

# Завершение
echo -e "\n${GREEN}=============================================${NC}"
echo -e "${GREEN}       ГЛУБОКАЯ ОЧИСТКА ЗАВЕРШЕНА!          ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "\n${BLUE}Ваш Mac теперь намного чище и должен работать быстрее!${NC}"
echo -e "\n${YELLOW}Было свободно: $DISK_SPACE_BEFORE${NC}"
echo -e "${GREEN}Сейчас свободно: $DISK_SPACE_AFTER${NC}"
echo -e "${CYAN}Примерно очищено: $TOTAL_SPACE_CLEARED_READABLE${NC}\n"
echo -e "${YELLOW}Примечание: Некоторые операции требуют sudo, если они не выполнены, запустите скрипт с sudo${NC}\n"
