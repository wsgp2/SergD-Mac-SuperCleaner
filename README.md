# 🧹 SergD Mac SuperCleaner

Единый рабочий инструмент — скрипт `mac-cleaner-pro.sh`. Все сторонние проекты и исходники перенесены в `junkyard/`, чтобы не отвлекать.

## 📦 Установка

```bash
git clone https://github.com/wsgp2/SergD-Mac-SuperCleaner.git
cd SergD-Mac-SuperCleaner
chmod +x mac-cleaner-pro.sh install.sh
./install.sh   # создаст ярлык serg-cleaner
```

## 🔥 Запуск

```bash
# стандартная очистка
./mac-cleaner-pro.sh

# с правами администратора (рекомендуется)
sudo ./mac-cleaner-pro.sh

# полезные флаги
./mac-cleaner-pro.sh -n        # dry-run: показать, что будет удалено
./mac-cleaner-pro.sh -y        # авто-подтверждения (для будущих опций)
./mac-cleaner-pro.sh -D        # дополнительно чистить Downloads (>30 дней)
```

## 📊 Что очищается
- **Браузеры**: Chrome, Safari, Firefox, Edge, Brave, Arc, Яндекс.Браузер
- **Система**: кэши `/Library`, `/private/var/folders`, временные каталоги, логи, корзина
- **Apple**: Mail, Messages, iOS бэкапы, iTunes/Music, App Store, CrashReporter
- **Dev**: Xcode (DerivedData, Archives, DeviceSupport, симулятор), Homebrew, npm, yarn, pip, Docker, Gradle, Maven
- **Приложения**: Telegram, Slack, Discord, Spotify, JetBrains IDEs
- **Оптимизация**: DNS кэш, локальные снимки Time Machine, индекс Spotlight

## 🔐 Безопасность и стабильность
- Корректная работа при `sudo` (очистка в домашней папке реального пользователя)
- Безопасное удаление через `find -mindepth 1` (включая скрытые файлы)
- Режим `--dry-run` для проверки, что будет удалено
- Проверка наличия утилит перед вызовом (`docker`, `brew`, `npm`, и т.д.)
- Лог в `/tmp/mac-cleaner-YYYYmmdd-HHMMSS.log`

## 📝 Лицензия
MIT License

## Контакты
- Telegram: https://t.me/sergei_dyshkant
- GitHub: https://github.com/wsgp2
