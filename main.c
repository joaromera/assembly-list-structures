#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test(){
    // Testing strLen
    char* test = "";
    int len = strLen(test);
    assert(len == 0);

    test = "h";
    len = strLen(test);
    assert(len == 1);

    test = "hola mundo!";
    len = strLen(test);
    assert(len == 11);

    test = "hola\0 mundo!";
    len = strLen(test);
    assert(len == 4);

    // Testing strClone
    test = "";
    char* clone = strClone(test);
    assert(strcmp(test, clone) == 0);

    test = "A";
    char* clone2 = strClone(test);
    assert(strcmp(test, clone2) == 0);

    test = "hola";
    char* clone3 = strClone(test);
    assert(strcmp(test, clone3) == 0);

    test = "hola mundo!";
    char* clone4 = strClone(test);
    assert(strcmp(test, clone4) == 0);

    // Testing strCmp
    test = "";
    char* cmp = "";
    assert(strCmp(test, cmp) == 0);

    test = "hola, mundo!";
    cmp = "hola, mundo!";
    assert(strCmp(test, cmp) == 0);

    test = "a";
    cmp = "b";
    assert(strCmp(test, cmp) == 1);
    assert(strCmp(cmp, test) == -1);

    test = "19";
    cmp = "138";
    assert(strCmp(test, cmp) == -1);
    assert(strCmp(cmp, test) == 1);

    char* cc = strConcat(strClone(test), strClone(cmp));
    assert(strcmp(cc, "19138") == 0);
    printf("%s\n",cc);

    char* empty_str = "";
    
    char* cc1 = strConcat(strClone(empty_str), strClone(empty_str));
    assert(strcmp(cc1, empty_str) == 0);
    printf("%s\n",cc1);

    char* non_empty_str = "hello world";
    
    char* cc2 = strConcat(strClone(empty_str), strClone(non_empty_str));
    assert(strcmp(cc2, non_empty_str) == 0);
    printf("%s\n",cc2);

    char* cc3 = strConcat(strClone(non_empty_str), strClone(empty_str));
    assert(strcmp(cc3, non_empty_str) == 0);
    printf("%s\n",cc3);

    list_t* list_test = listNew();
}

void test_n3tree(FILE *pfile){

}

void test_nTable(FILE *pfile){
    
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test();
    test_n3tree(pfile);
    test_nTable(pfile);
    fclose(pfile);
    return 0;
}


