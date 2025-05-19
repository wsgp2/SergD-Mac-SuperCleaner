# 📝 Детальное описание очистки SergD Mac SuperCleaner

## 📊 Полный список очищаемых компонентов

### 🔄 БЛОК 1: КОРЗИНА И ЗАГРУЗКИ

| Компонент | Путь | Описание | Безопасность |
|---|---|---|---|
| 🗑️ Корзина | `~/.Trash/` | Удаляет файлы, помещенные в корзину | ✅ Безопасно |
| 🗑️ Корзина внешних дисков | `/Volumes/*/.Trashes/` | Очищает корзину внешних дисков | ✅ Безопасно |
| 📥 Старые загрузки | `~/Downloads/` | Опционально удаляет файлы из загрузок старше 30 дней | ⚠️ Внимание |

### 🌐 БЛОК 2: КЭШ БРАУЗЕРОВ

| Браузер | Очищаемые компоненты | Путь | Безопасность |
|---|---|---|---|
| 🌐 **Chrome** | Общий кэш | `~/Library/Caches/Google/Chrome/` | ✅ Безопасно |
|  | Кэш страниц | `~/Library/Application Support/Google/Chrome/Default/Cache/` | ✅ Безопасно |
|  | Service Workers | `~/Library/Application Support/Google/Chrome/Default/Service Worker/` | ✅ Безопасно |
|  | Кэш расширений | `~/Library/Application Support/Google/Chrome/Default/Storage/ext/` | ✅ Безопасно |
|  | Шейдеры | `~/Library/Application Support/Google/Chrome/ShaderCache/` | ✅ Безопасно |
| 🧭 **Safari** | Общий кэш | `~/Library/Caches/com.apple.Safari/` | ✅ Безопасно |
|  | LocalStorage | `~/Library/Safari/LocalStorage/` | ✅ Безопасно |
|  | Базы данных | `~/Library/Safari/Databases/` | ✅ Безопасно |
|  | Service Workers | `~/Library/Safari/ServiceWorkers/` | ✅ Безопасно |
|  | Контейнеры | `~/Library/Containers/com.apple.Safari/Data/Library/Caches/` | ✅ Безопасно |
| 🦊 **Firefox** | Общий кэш | `~/Library/Caches/Mozilla/Firefox/` | ✅ Безопасно |
|  | Кэш профилей | `~/Library/Application Support/Firefox/Profiles/*/cache2/` | ✅ Безопасно |
|  | Startup кэш | `~/Library/Application Support/Firefox/Profiles/*/startupCache/` | ✅ Безопасно |
| 🦁 **Brave** | Кэш Brave | `~/Library/Caches/BraveSoftware/` | ✅ Безопасно |
| 🔵 **Edge** | Общий кэш | `~/Library/Caches/Microsoft Edge/` | ✅ Безопасно |
|  | Кэш страниц | `~/Library/Application Support/Microsoft Edge/Default/Cache/` | ✅ Безопасно |
| 🔍 **Яндекс.Браузер** | Кэш | `~/Library/Caches/YandexBrowser/` | ✅ Безопасно |
| 🌈 **Arc** | Кэш | `~/Library/Caches/company.thebrowser.Browser/` | ✅ Безопасно |
|  | Кэш данных | `~/Library/Application Support/Arc/User Data/Default/Cache/` | ✅ Безопасно |

### 💻 БЛОК 3: СИСТЕМНЫЙ КЭШ

| Компонент | Путь | Описание | Безопасность |
|---|---|---|---|
| 🖥️ Системный кэш | `/Library/Caches/` | Системные кэши (требует sudo) | ✅ Безопасно |
| 👤 Пользовательский кэш | `~/Library/Caches/` | Кэши пользовательских приложений | ✅ Безопасно |
| 📁 Временные системные папки | `/private/var/folders/` | Временные файлы системы | ✅ Безопасно |
| 📝 Системные логи | `/Library/Logs/` | Журналы работы системы | ✅ Безопасно |
| 📝 Пользовательские логи | `~/Library/Logs/` | Логи пользовательских приложений | ✅ Безопасно |
| 📝 ASL логи | `/private/var/log/asl/*.asl` | Журналы системных событий | ✅ Безопасно |
| 📝 Диагностические сообщения | `/var/log/DiagnosticMessages/` | Файлы диагностики | ✅ Безопасно |
| 🗂️ Временные файлы | `/private/var/tmp/` | Временные данные системы | ✅ Безопасно |
| 🗂️ Общие временные файлы | `/tmp/` | Общие временные файлы | ✅ Безопасно |
| 🖨️ Спулер печати | `/var/spool/cups/tmp/` | Временные файлы печати | ✅ Безопасно |

### 🍎 БЛОК 4: ПРИЛОЖЕНИЯ APPLE

| Приложение | Компонент | Путь | Безопасность |
|---|---|---|---|
| 📧 **Mail** | Кэш | `~/Library/Containers/com.apple.mail/Data/Library/Caches/` | ✅ Безопасно |
|  | Индекс | `~/Library/Mail/V*/MailData/Envelope Index/` | ✅ Безопасно |
| 💬 **Messages** | Вложения | `~/Library/Messages/Attachments/` | ⚠️ Внимание |
|  | Архивы | `~/Library/Messages/Archives/` | ⚠️ Внимание |
| 🎵 **iTunes/Music** | Кэш iTunes | `~/Library/Caches/com.apple.itunes/` | ✅ Безопасно |
|  | Кэш Music | `~/Library/Caches/com.apple.Music/` | ✅ Безопасно |
| 🛒 **App Store** | Кэш | `~/Library/Caches/com.apple.appstore/` | ✅ Безопасно |
| 📱 **iOS** | Бэкапы устройств | `~/Library/Application Support/MobileSync/Backup/` | ⚠️ Внимание |
| 🪦 **Отчеты сбоев** | CrashReporter | `/Library/Application Support/CrashReporter/` | ✅ Безопасно |
| 🔄 **Обновления** | Обновления | `/Library/Updates/` | ✅ Безопасно |

### 🛠️ БЛОК 5: ИНСТРУМЕНТЫ РАЗРАБОТЧИКА

| Инструмент | Компонент | Путь | Безопасность |
|---|---|---|---|
| 🧰 **Xcode** | DerivedData | `~/Library/Developer/Xcode/DerivedData/` | ✅ Безопасно |
|  | Archives | `~/Library/Developer/Xcode/Archives/` | ⚠️ Внимание |
|  | iOS DeviceSupport | `~/Library/Developer/Xcode/iOS DeviceSupport/` | ✅ Безопасно |
|  | Симулятор | `~/Library/Developer/CoreSimulator/Caches/` | ✅ Безопасно |
| 🐳 **Docker** | Образы и контейнеры | Использует команду `docker system prune -af` | ⚠️ Внимание |
| 📦 **npm** | Кэш пакетов | Использует команду `npm cache clean --force` | ✅ Безопасно |
| 🍺 **Homebrew** | Кэш пакетов | Использует команду `brew cleanup -s` | ✅ Безопасно |
| 🐍 **pip** | Кэш пакетов | Использует команду `pip cache purge` | ✅ Безопасно |
| 🧩 **Gradle** | Кэш сборки | `~/.gradle/caches/` | ✅ Безопасно |
| 🧩 **Maven** | Репозиторий | `~/.m2/repository/` | ✅ Безопасно |
| 🧵 **Yarn** | Кэш пакетов | Использует команду `yarn cache clean` | ✅ Безопасно |

### 💬 БЛОК 6: ОЧИСТКА ПРИЛОЖЕНИЙ

| Приложение | Компонент | Путь | Безопасность |
|---|---|---|---|
| 🔵 **Slack** | Кэш | `~/Library/Application Support/Slack/Cache/` | ✅ Безопасно |
|  | Service Workers | `~/Library/Application Support/Slack/Service Worker/CacheStorage/` | ✅ Безопасно |
| 💻 **VS Code** | Кэш | `~/Library/Application Support/Code/Cache/` | ✅ Безопасно |
|  | Кэшированные данные | `~/Library/Application Support/Code/CachedData/` | ✅ Безопасно |
|  | Рабочие области | `~/Library/Application Support/Code/User/workspaceStorage/` | ⚠️ Внимание |
| ✈️ **Telegram** | Стикеры | `~/Library/Group Containers/*.ru.keepcoder.Telegram/stickers/` | ✅ Безопасно |
|  | Анимации | `~/Library/Group Containers/*.ru.keepcoder.Telegram/lottie/` | ✅ Безопасно |
|  | Медиа-кэш | `~/Library/Group Containers/*.ru.keepcoder.Telegram/mediacache/` | ✅ Безопасно |
| 🎮 **Discord** | Кэш | `~/Library/Application Support/discord/Cache/` | ✅ Безопасно |
| 🎵 **Spotify** | Кэш | `~/Library/Application Support/Spotify/PersistentCache/` | ✅ Безопасно |
| 🎨 **Adobe** | Кэш медиа | `~/Library/Application Support/Adobe/Common/Media Cache Files/` | ✅ Безопасно |
| 🚀 **JetBrains** | Кэш | `~/Library/Caches/JetBrains/` | ✅ Безопасно |
|  | Логи | `~/Library/Logs/JetBrains/` | ✅ Безопасно |

### 🔄 БЛОК 7: СИСТЕМНАЯ ПАМЯТЬ

| Компонент | Описание | Команда | Безопасность |
|---|---|---|---|
| 🔄 **DNS кэш** | Кэш DNS-запросов | `sudo dscacheutil -flushcache` и<br>`sudo killall -HUP mDNSResponder` | ✅ Безопасно |
| 💾 **Неактивная память** | Очистка неактивной RAM | `sudo purge` | ✅ Безопасно |

### ⚙️ БЛОК 8: ОПТИМИЗАЦИЯ

| Компонент | Описание | Команда | Безопасность |
|---|---|---|---|
| 🕒 **Time Machine** | Локальные снимки | `tmutil thinlocalsnapshots / 9999999999` | ✅ Безопасно |
| 🔍 **Spotlight** | Индекс поиска | `sudo mdutil -E /` | ✅ Безопасно |

## 🔍 Обозначения безопасности

- ✅ **Безопасно** — Можно смело удалять, данные будут восстановлены системой при необходимости
- ⚠️ **Внимание** — Стоит проверить содержимое перед удалением (затрагивает кэшированные данные, которые могут быть полезны)
- ❌ **Опасно** — Не рекомендуется удалять (не используется в скрипте)

## 🔄 Частота использования

Рекомендуемая частота запуска SergD Mac SuperCleaner:

- **Еженедельно** — Для обычных пользователей
- **Ежедневно** — Для разработчиков и профессиональных пользователей
- **После установки/удаления** крупных программ
- **При нехватке** дискового пространства
