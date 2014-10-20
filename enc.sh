#!/bin/bash

function printcode(){

echo """#include <sstream>
#include <iostream>
#include <iomanip>

std::ostream& crypt(std::ostream& os, const std::string& s1, const std::string s2){
  std::stringstream ss1(s1), ss2(s2);
  ss1 << std::hex;
  ss2 << std::hex;

  while(true){
    uint16_t word1, word2, wordc;
    ss1 >> word1;
    ss2 >> word2;

    if(!ss1.good() || !ss2.good()) break;
    wordc = word1 ^ word2;

    os.write((char*)&wordc, sizeof(wordc));
  }
  return os;
}

int main(int argc, char** argv){
  std::string key(
$1
  );

  std::string msg(
$2
  );

  crypt(std::cout, msg, key);
}"""

}

function to_string(){
  cut -d " " -f 2- | sed -e '$ d' -e 's/^\(.*\)$/      "\1 "/'
}

pln=$(hexdump $1 | to_string )
dd if=/dev/urandom of=$1.key bs=$(du $1 -b | cut -f 1) count=1
key=$(hexdump $1.key | to_string )

printcode "$key" "$pln" > "$1.encode.cpp"
clang++ -std=c++11 -o $1.encode.x -xc++ "$1.encode.cpp"

msg=$(./$1.encode.x | hexdump -- | to_string )
printcode "$key" "$msg" > $1.decode.cpp
clang++ -std=c++11 -o $1.decode.x -xc++ "$1.decode.cpp"

echo -e "PLN:\n$pln\n\n"
echo -e "KEY:\n$key\n\n"
echo -e "MSG:\n$msg\n\n"
