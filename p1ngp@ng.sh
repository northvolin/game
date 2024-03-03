#!/bin/bash

# Размеры игрового поля
FIELD_WIDTH=40
FIELD_HEIGHT=20

# Размеры платформы
PLATFORM_WIDTH=5
PLATFORM_HEIGHT=1

# Начальные координаты и скорость мяча
BALL_X=$((FIELD_WIDTH / 2))
BALL_Y=$((FIELD_HEIGHT / 2))
BALL_DX=1
BALL_DY=-1

# Настраиваем терминал на неблокирующий ввод
setup_input() {
    stty -echo             # Отключаем вывод вводимых символов на экран
    stty -icanon           # Переходим в режим неблокирующего ввода
    stty min 0             # Минимальное количество символов для завершения чтения
    stty time 1            # Тайм-аут для чтения в десятых долях секунды
}

# Возвращаем исходные настройки терминала
reset_input() {
    stty sane              # Возвращаем терминал в обычный режим
}

# Функция отрисовки игрового поля
draw_field() {
    clear  # Очищаем экран перед отрисовкой
    for ((i=0; i<$FIELD_HEIGHT; i++)); do
        for ((j=0; j<$FIELD_WIDTH; j++)); do
            if [[ $i -eq 0 || $i -eq $(($FIELD_HEIGHT - 1)) || $j -eq 0 || $j -eq $(($FIELD_WIDTH - 1)) ]]; then
                echo -n "#"  # Рисуем границы поля
            elif [[ $i -eq $BALL_Y && $j -eq $BALL_X ]]; then
                echo -n "O"  # Рисуем мяч
            else
                echo -n " "  # Заполняем поле пустым пространством
            fi
        done
        echo ""  # Новая строка после каждой строки поля
    done
}

# Функция отрисовки платформы
draw_platform() {
    local platform_x=$1
    local platform_y=$2
    tput cup $platform_y $platform_x  # Перемещаем курсор на начальную позицию платформы
    for ((j=0; j<$PLATFORM_WIDTH; j++)); do
        echo -n "="  # Рисуем платформу
    done
}

# Основная логика игры
main() {
    setup_input
    trap reset_input EXIT  # Гарантируем возврат настроек терминала при выходе

    local platform_x=$((($FIELD_WIDTH - $PLATFORM_WIDTH) / 2))
    local platform_y=$(($FIELD_HEIGHT - 2))

    while true; do
        draw_field  # Отрисовка поля
        draw_platform $platform_x $platform_y  # Отрисовка платформы

        # Чтение ввода от пользователя
        read -s -n 1 input
        case "$input" in
            a)  # Если нажата 'a', двигаем платформу влево
                if (( platform_x > 1 )); then
                    platform_x=$((platform_x - 1))
                fi
                ;;
            d)  # Если нажата 'd', двигаем платформу вправо
                if (( platform_x < $(($FIELD_WIDTH - $PLATFORM_WIDTH - 1)) )); then
                    platform_x=$((platform_x + 1))
                fi
                ;;
        esac

        # Обновление и отрисовка мяча
        BALL_X=$((BALL_X + BALL_DX))
        BALL_Y=$((BALL_Y + BALL_DY))

        # Отскок от границ
        if ((BALL_X <= 1 || BALL_X >= FIELD_WIDTH - 2)); then
            BALL_DX=$(( -BALL_DX ))
        fi
        if ((BALL_Y <= 1)); then
            BALL_DY=$(( -BALL_DY ))
        fi

        # Отскок от платформы
        if ((BALL_Y == platform_y - 1 && BALL_X >= platform_x && BALL_X <= platform_x + PLATFORM_WIDTH - 1)); then
            BALL_DY=$(( -BALL_DY ))
        fi

        # Проверка на проигрыш (мяч упал вниз)
        if ((BALL_Y >= FIELD_HEIGHT - 1)); then
            echo "Game Over"
            break
        fi

        sleep 0.05  # Короткая задержка для контроля скорости игры
    done

    reset_input  # Возвращаем исходные настройки терминала
}

main

###digglega###