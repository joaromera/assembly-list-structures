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

    // // Testing strClone & strDelete
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

    // // Testing strCmp
    test = "";
    char* cmp = "";
    char* tsc = strClone(test);
    char* tsc2 = strClone(cmp);
    assert(strCmp(tsc, tsc2) == 0);
    strDelete(tsc);
    strDelete(tsc2);

    test = "hola, mundo!";
    cmp = "hola, mundo!";
    
    char* tsc3 = strClone(test);
    char* tsc4 = strClone(cmp);
    assert(strCmp(tsc3, tsc4) == 0);
    strDelete(tsc3);
    strDelete(tsc4);

    test = "1";
    cmp = "2";
    char* tsc5 = strClone(test);
    char* tsc6 = strClone(cmp);
    assert(strCmp(tsc5,tsc6) == 1);
    assert(strCmp(tsc6,tsc5) == -1);    
    strDelete(tsc5);
    strDelete(tsc6);

    test = "0";
    cmp = "0";
    char* tsc7 = strClone(test);
    char* tsc8 = strClone(cmp);
    assert(strCmp(tsc7,tsc8) == 0);
    assert(strCmp(tsc8,tsc7) == 0);    
    strDelete(tsc7);
    strDelete(tsc8);

    test = "19";
    cmp = "138";
    char* tsc9 = strClone(test);
    char* tsc10 = strClone(cmp);
    assert(strCmp(tsc9,tsc10) == -1);
    assert(strCmp(tsc10,tsc9) == 1);    
    strDelete(tsc9);
    strDelete(tsc10);

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

    // // Testing strPrint
    FILE* pFile = fopen("file", "a");
    char* empty_str_cloned = strClone(empty_str);
    strPrint(empty_str_cloned,pFile);
    strDelete(empty_str_cloned);
    fprintf(pFile, "\n");

    // // Testing listNew
    list_t* list_test = listNew();
    listPrint(list_test, pFile, NULL);
    listPrint(list_test, pFile, (funcPrint_t*)& strPrint);
    fprintf(pFile, "\n");
    
    // // Testing add first with list print and strprint
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

    // // Testing list delete
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

    // // Testing add last
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
    fprintf(pFile, "\n");

    // // // Testing list delete
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

    // // Testing N3TREE new
    n3tree_t* n3tree_test = n3treeNew();
    n3treeAdd(n3tree_test, strClone("1"),(funcCmp_t*)&strCmp);
    printf("tree is in %p and points to %p\n", n3tree_test, n3tree_test->first);

    // // Test Remove Eq
    n3treeAdd(n3tree_test, strClone("2"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("4"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("8"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("0"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("3"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("3"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("3"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("3"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("3"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test, strClone("9"),(funcCmp_t*)&strCmp);
    printf("tree is in %p and points to %p\n", n3tree_test, n3tree_test->first);

    // // Test delete
    n3treeDelete(n3tree_test,(funcDelete_t*)&strDelete);

    n3tree_t* n3tree_test2 = n3treeNew();
    n3treeAdd(n3tree_test2, strClone("1"),(funcCmp_t*)&strCmp);
    n3treeAdd(n3tree_test2, strClone("1"),(funcCmp_t*)&strCmp);
    n3treeDelete(n3tree_test2,(funcDelete_t*)&strDelete);

    // // NTABLE
    nTable_t *n = nTableNew(32);
    char* strings[10] = {"aa","bb","dd","ff","00","zz","cc","ee","gg","hh"};
    nTableAdd(n, 0, strClone(strings[0]), (funcCmp_t*)&strCmp);
    nTableAdd(n, 0, strClone(strings[1]), (funcCmp_t*)&strCmp);
    nTableAdd(n, 1, strClone(strings[0]), (funcCmp_t*)&strCmp);
    for(int s=0;s<32;s++)
    {
        for(int i=0;i<10;i++)
        {
            nTableAdd(n, s, strClone(strings[i]), (funcCmp_t*)&strCmp);
        }
    }
    for(int s=0;s<100;s++)
    {
        for(int i=0;i<100;i++)
        {
            nTableRemoveSlot(n, s % 32, strClone(strings[i % 10]), (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
        }
    }
    nTableRemoveSlot(n, 0, strClone(strings[0]), (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    examine_ntable(n,32);
    nTableDelete(n, (funcDelete_t*)&strDelete);
}

void jodita() {};

void test_n3tree(FILE *pfile){
    n3tree_t* n3t = n3treeNew();
    char* strings[10] = {"1","2","3","1","2","3","1","2","3","4","5"};
    for(int i = 0; i < 10; ++i)
    {
        n3treeAdd(n3t, strClone(strings[i]), (funcCmp_t*)&strCmp);
    }
    n3treePrint(n3t, pfile, (funcPrint_t*) &strPrint);
    n3treeDelete(n3t,(funcDelete_t*)&strDelete);
}

void test_nTable(FILE *pfile){
    nTable_t *nt = nTableNew(33);
    char* strings[10] = {"hola",","," ","mundo","!","Hello",", ","awesome","world","!"};
    for(int i = 0; i < 33; ++i)
    {
        nTableAdd(nt, i, strClone(strings[i % 10]), (funcCmp_t*) &strCmp);
    }
    // nTablePrint(nt, pfile, (funcPrint_t*) &strPrint);
    nTableDelete(nt, (funcDelete_t*)&strDelete);
}

void examine_ntable(nTable_t* t, int size)
{
    printf("Examine ntable at: %p with value %p\n", &t, t);
    printf("List array at %p\n", t->listArray);
    printf("Of size %i\n", t->size);
    if (t == NULL) return;
    list_t** first = t->listArray;

    for (int i = 0; i < size; ++i)
    {
        printf("Slot %i points at %p\n", i, first);
        examine_list(*first);
        first = (list_t**) (8 + (int) first);
    }
}

void examine_tree(n3treeElem_t* elem)
{
    if (elem == NULL) return;
    examine_tree(elem->left);
    print_tri(elem);
    printf("\n");
    examine_tree(elem->right);
}

void print_tri(n3treeElem_t* elem)
{   
    if (elem == NULL) return;
    printf("\tData at %p\t has: %p\t is: %s\n", &elem->data, elem->data, elem->data);
    printf("\tLeft at %p\t has: %p\n", &elem->left, elem->left);
    printf("\tCenter at %p\t has: %p\n", &elem->center, elem->center);
    examine_list(elem->center);
    printf("\tRight at %p\t has: %p\n", &elem->right, elem->right);
}

void examine_list(list_t* l)
{
    // printf("\tList at: %p\t\t\n", l);
    printf("\t\tFirst at: %p\t is:\t%p\n", &l->first, l->first);
    printf("\t\tLast at: %p\t is:\t%p\n", &l->last, l->last);
    

    listElem_t* elem = l->first;
    if (elem != NULL) {
        printf("\t\t\tElem->data at: %p\t addr: %p\tis %s\n", &elem->data, elem->data, elem->data);
        printf("\t\t\tElem->next at: %p\t addr: %p\t\n", &elem->next, elem->next);
        printf("\t\t\tElem->prev at: %p\t addr: %p\t\n", &elem->prev, elem->prev);
        printf("\n");
        elem = elem->next;
    }

    while (elem != NULL) {
        printf("\t\t\tElem->data at: %p\t addr: %p\tis %s\n", &elem->data, elem->data, elem->data);
        printf("\t\t\tElem->next at: %p\t addr: %p\t\n", &elem->next, elem->next);
        printf("\t\t\tElem->prev at: %p\t addr: %p\t\n", &elem->prev, elem->prev);
        printf("\n");
        elem = elem->next;
    }
}

void examine_str(char* str)
{
    printf("%15p\t%15s\n", str);
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test();
    // test_n3tree(pfile);
    // test_nTable(pfile);
    fclose(pfile);
    
    return 0;
}