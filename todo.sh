#!/bin/sh

export GUM_CHOOSE_CURSOR_PREFIX="[•] "
export GUM_CHOOSE_SELECTED_PREFIX="[x] "
export GUM_CHOOSE_UNSELECTED_PREFIX="[ ] "
export FOREGROUND="#C1D8C3"
export BORDER_FOREGROUND="#6A9C89"
export BORDER="double"
export GUM_CHOOSE_SELECTED_FOREGROUND="#54B435"
export GUM_CHOOSE_CURSOR_FOREGROUND="#379237"

file="./todo.txt"
temp_file="./todo.txt.tmp"

list() {
    cat -n "$file"
}

add() {
    task=$(gum input --placeholder "What's the task title?")
    echo "[ ] $task" >> "$file"
}

update() {
    if [ -s "$file" ]; then
        selected_tasks=$(
            sed '/\[\s\?\]\s.*/d' "$file" | # remove all tasks that are not selected
            sed 's/\[x\]\s//g' | # remove all "[x] " prefixes
            sed ':a;N;$!ba;s/\n/,/g' # join all lines with a comma
        )

        updates=$(
            sed 's/\[[ |x]\]\s//g' "$file" | 
            gum choose --no-limit --selected "$selected_tasks"
        )

        while IFS= read -r line; do
            task=$(echo "$line" | sed 's/\[[ |x]\]\s//g') # remove o prefixo da tarefa
            if echo "$updates" | grep -q "$task"; then
                # Se a tarefa estiver na lista de atualizações, marque-a como concluída
                echo "[x] $task" >> "$temp_file"
            else
                # Caso contrário, marque-a como não concluída
                echo "[ ] $task" >> "$temp_file"
            fi
        done < "$file"

        mv "$temp_file" "$file"
    else
        gum style --padding "1 1" --margin "1 2" "Just chilling. Nothing to do yet"
    fi
}

clear() {
    gum confirm && (\
        sed '/\[x\]\s.*/d' "$file" > "$temp_file" | 
        mv "$temp_file" "$file"
    )
}

case "$1" in
    ls)
        list
        ;;
    *)
        while true; do
            option=$(gum choose "See Tasks" "Add Task" "Clear Completed Tasks" "Sair")

            case "$option" in
                "See Tasks")
                    update
                    ;;
                "Add Task")
                    add
                    ;;
                "Clear Completed Tasks")
                    clear
                    ;;
                "Sair")
                    exit 0
                    ;;
            esac
        done
        ;;
esac