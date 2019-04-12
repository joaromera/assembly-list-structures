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

    // Testing strClone & strDelete
    test = "";
    char* clone = strClone(test);
    assert(strcmp(test, clone) == 0);
    strDelete(clone);

    test = "A";
    char* clone2 = strClone(test);
    assert(strcmp(test, clone2) == 0);
    strDelete(clone2);

    test = "hola";
    char* clone3 = strClone(test);
    assert(strcmp(test, clone3) == 0);
    strDelete(clone3);

    test = "hola mundo!";
    char* clone4 = strClone(test);
    assert(strcmp(test, clone4) == 0);
    strDelete(clone4);

    // Testing strCmp
    test = "";
    char* cmp = "";
    assert(strCmp(strClone(test), strClone(cmp)) == 0);

    test = "hola, mundo!";
    cmp = "hola, mundo!";
    assert(strCmp(strClone(test), strClone(cmp)) == 0);

    test = "1";
    cmp = "2";
    assert(strCmp(strClone(test), strClone(cmp)) == 1);
    assert(strCmp(strClone(cmp), strClone(test)) == -1);

    assert(strCmp(strClone("0"), strClone("0")) == 0);

    test = "19";
    cmp = "138";
    assert(strCmp(test, cmp) == -1);
    assert(strCmp(cmp, test) == 1);

    test = "hola ";
    cmp = "mundo!";

    // Testing strConcat
    char* cc = strConcat(strClone(test), strClone(cmp));
    assert(strcmp(cc, "hola mundo!") == 0);
    printf("%s\n",cc);
    strDelete(cc);

    char* empty_str = "";
    
    char* cc1 = strConcat(strClone(empty_str), strClone(empty_str));
    assert(strcmp(cc1, empty_str) == 0);
    printf("%s\n",cc1);
    strDelete(cc1);

    char* non_empty_str = "hello world";
    
    char* cc2 = strConcat(strClone(empty_str), strClone(non_empty_str));
    assert(strcmp(cc2, non_empty_str) == 0);
    printf("%s\n",cc2);
    strDelete(cc2);

    char* cc3 = strConcat(strClone(non_empty_str), strClone(empty_str));
    assert(strcmp(cc3, non_empty_str) == 0);
    printf("%s\n",cc3);
    strDelete(cc3);

    // Testing strPrint
    FILE* pFile = fopen("file", "a");
    strPrint(strClone(empty_str),pFile);
    fprintf(pFile, "\n");

    // Testing listNew
    list_t* list_test = listNew();
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");
    
    // Testing add first with list print and strprint
    listAddFirst(list_test, strClone(non_empty_str));
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");
    
    listAddFirst(list_test, strClone(test));
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");

    listAddFirst(list_test, strClone(non_empty_str));
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");

    // Testing list delete
    listRemoveLast(list_test, (funcDelete_t*)& strDelete);
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");

    listRemoveLast(list_test, (funcDelete_t*)& strDelete);
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");

    listRemoveLast(list_test, (funcDelete_t*)& strDelete);
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");

    // Testing add last
    listAddLast(list_test, strClone(non_empty_str));
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");
    
    listAddLast(list_test, strClone(test));
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");

    listAddLast(list_test, strClone(non_empty_str));
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    FILE *pr = fopen("printRev","w");
    listPrintReverse(list_test, pr, (funcPrint_t*)& strPrint);
    fclose(pr);
    fprintf(pFile, "\n");

    // // Testing list delete
    listRemoveFirst(list_test, (funcDelete_t*)& strDelete);
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");

    listRemoveFirst(list_test, NULL);
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");

    listRemoveFirst(list_test, NULL);
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    listDelete(list_test, (funcDelete_t*)& strDelete);
    fprintf(pFile, "\n");

    fclose(pFile);

    // Testing N3TREE new
    n3tree_t* n3tree_test = n3treeNew();
    n3treeAdd(n3tree_test, strClone("1"),(funcCmp_t*)&strCmp);

    // Test Remove Eq
    n3treeRemoveEq(n3tree_test,(funcDelete_t*)&strDelete);
    n3treeAdd(n3tree_test, strClone("4"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("8"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("2"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("0"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("3"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("3"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("3"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("3"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("3"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("9"),(funcCmp_t*)&strCmp);

    FILE* ntpt = fopen("n3treeprint","w");
    n3treePrint(n3tree_test, ntpt, (funcPrint_t*)& strPrint);
    fclose(ntpt);
    // Test delete
    n3treeDelete(n3tree_test,(funcDelete_t*)&strDelete);

    n3tree_t* n3tree_test2 = n3treeNew();
    n3treeAdd(n3tree_test2, strClone("1"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test2, strClone("1"),(funcCmp_t*)&strCmp);
    n3treeDelete(n3tree_test2,(funcDelete_t*)&strDelete);

    // NTABLE
    nTable_t *n = nTableNew(32);
    char* strings[10] = {"aa","bb","dd","ff","00","zz","cc","ee","gg","hh"};
    for(int s=0;s<32;s++)
    {
        for(int i=0;i<10;i++)
        {
            nTableAdd(n, s, strClone(strings[i]), (funcCmp_t*)&strCmp);
        }
    }
    // nTableRemoveSlot(n, 1, strClone(strings[0]), (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    // nTableDelete(n, (funcDelete_t*)&strDelete);
}

void test_n3tree(FILE *pfile){
    n3tree_t* n3t = n3treeNew();
    char* strings[10] = {"1","2","3","1","2","3","1","2","3"};
    for(int i = 0; i < 10; ++i)
    {
        n3treeAdd(n3t, strClone(strings[i]), (funcCmp_t*)&strCmp);
    }
    n3treePrint(n3t, pfile, (funcPrint_t*) &strPrint);
}

void test_nTable(FILE *pfile){
    nTable_t *nt = nTableNew(33);
    char* strings[10] = {"hola",","," ","mundo","!","Hello",", ","awesome","world","!"};
    for(int i = 0; i < 33; ++i)
    {
        nTableAdd(nt, i, strClone(strings[i % 33]), (funcCmp_t*) &strCmp);
    }
    nTablePrint(nt, pfile, (funcPrint_t*) &strPrint);
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    // test();
    test_n3tree(pfile);
    // test_nTable(pfile);
    fclose(pfile);
    return 0;
}