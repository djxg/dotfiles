#!/bin/bash

sudo -v

# refer  spf13-vim bootstrap.sh`
# BASEDIR=$(dirname $0)
# cd $BASEDIR
# CURRENT_DIR=`pwd`
# or you can try:
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
}


echo -e "\033[40;32m Step1: backing up current vim config \033[0m"
today=`date +%Y%m%d`
for i in $HOME/.gvimrc $HOME/.vimrc $HOME/.vim; do [ -e $i ] && [ ! -L $i ] && mv $i $i.$today; done
for i in $HOME/.gvimrc $HOME/.vimrc $HOME/.vim; do [ -L $i ] && unlink $i ; done


echo -e "\033[40;32m Step2: setting up symlinks \033[0m"
mkdir -p $CURRENT_DIR/.vim
lnif $CURRENT_DIR/.vimrc $HOME/.vimrc
lnif "$CURRENT_DIR/.vim" "$HOME/.vim"
lnif "$CURRENT_DIR/.vim/autoload/plug.vim" "$HOME/.vim/autoload/plug.vim"
lnif "$CURRENT_DIR/.vim/plugged/YouCompleteMe" "$HOME/.vim/plugged/YouCompleteMe"


echo -e "\033[40;32m Step3: update/install plugins using Vundle \033[0m"
system_shell=$SHELL
export SHELL="/bin/sh"

echo -e "\033[40;32m install the plug.vim from github \033[0m"
curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo -e "\033[40;32m install install all the plugins with plug.vim \033[0m"
# vim -u $HOME/.vimrc +PlugInstall! +PlugClean! +qall
vim -u $HOME/.vimrc +PlugInstall! +qall
export SHELL=$system_shell


echo -e "\033[40;32m Step4: compile YouCompleteMe \033[0m"
echo -e "\033[40;32m It will take a long time, just be patient! \033[0m"
echo -e "\033[40;32m If error,you need to compile it yourself \033[0m"
echo -e "\033[40;32m cd $CURRENT_DIR/.vim/plugged/YouCompleteMe/ && python install.py --clang-completer \033[0m"
# cd $CURRENT_DIR/.vim/plugged/YouCompleteMe/
cd $HOME/.vim/plugged/YouCompleteMe
git submodule update --init --recursive
if [ `which clang` ]   # check system clang
then
    python install.py --clang-completer --system-libclang   # use system clang
else
    python install.py --clang-completer
fi

cd $CURRENT_DIR
echo -e "\033[40;32m VIM Install Done, happy hacking! \033[0m"
