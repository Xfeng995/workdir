#!/bin/bash

while getopts "a:b:" opt; do
    case $opt in
        a) echo "Option -a with value $OPTARG" ;;
        b) echo "Option -b with value $OPTARG" ;;
        *) echo "Unknown option $opt" exit 1 ;;
        #\?) echo "Unknown option: -$OPTARG" >&2 exit 1 ;;
        #:) echo "Option -$OPTARG requires an argument." >&2 exit 1 ;;
    esac
done

# 使用 --help 选项来显示脚本的使用说明。
# 在帮助信息中，清晰地说明每个选项的含义和用法。
show_help() {
    echo "Usage: $0 [-a value] [-b value]"  
    echo "-a  Specify a value for option A"  
    echo "-b  Specify a value for option B"
}

# 检查必要的参数是否被提供。
# 验证参数的合法性，比如检查数字范围、文件路径是否存在等。
if [ "$#" -ne 2 ]; then    
    echo "Usage: $0 <arg1> <arg2>"    
    exit 1
fi


# 验证参数是否符合预期的格式，比如检查是否为数字、是否在某个范围内等。
if ! [[ "$arg_a" =~ ^[0-9]+$ ]]; then    
    echo "Error: Argument a must be a number."    
    exit 1
fi


# 不要硬编码参数的位置，使用变量或循环来处理参数。
for arg in "$@"; do  
    echo "Processing argument: $arg"
done


# 对于某些选项，可以提供一个合理的默认值，这样用户在不提供该选项时也能正常运行脚本。
output_file=${1:-"default.txt"}
echo "Using output file: $output_file"


