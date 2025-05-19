#!/bin/bash

# SergD Mac SuperCleaner - Установщик
# Автор: Sergei Dyshkant (SergD)

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}       SergD Mac SuperCleaner               ${NC}"
echo -e "${CYAN}          Установщик                        ${NC}"
echo -e "${CYAN}=============================================${NC}"

echo -e "\n${BLUE}Проверка прав на файлы...${NC}"
chmod +x mac-cleaner-pro.sh
echo -e "${GREEN}✓ Права установлены!${NC}"

echo -e "\n${BLUE}Создание ссылки в системных путях (потребуется пароль)...${NC}"
sudo ln -sf "$(pwd)/mac-cleaner-pro.sh" /usr/local/bin/serg-cleaner
echo -e "${GREEN}✓ Ссылка создана!${NC}"

echo -e "\n${GREEN}=============================================${NC}"
echo -e "${GREEN}       Установка завершена!                 ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "\n${BLUE}Теперь вы можете запустить очистку командой:${NC}"
echo -e "${YELLOW}serg-cleaner${NC}"
echo -e "\n${BLUE}Для запуска с правами администратора:${NC}"
echo -e "${YELLOW}sudo serg-cleaner${NC}"
echo -e "\n${BLUE}Наслаждайтесь чистым Mac!${NC}"
