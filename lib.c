#include "lib.h"

/** STRING **/

char* strRange(char* a, uint32_t i, uint32_t f) {
    // Ejemplos: strRange("ABC", 1, 1) → "B",
    // strRange("ABC", 10, 0) → "ABC",
    // strRange("ABC", 2, 10) → "C"
    int len_a = strLen(a);
    char* newStr;
    // Si i>f, retorna el mismo string pasado por par ́ametro
    if (i > f) {
        char* newStr = malloc(len_a + 1);
        int c = 0;
        while(c < len_a)
        {
            newStr[c] = a[c];
            ++c;
        }
        newStr[c] = 0;
        free(a);
        return newStr;
    }
    // si i>len, entonces retorna la string vac ́ıa
    if (i > len_a)
    {
        newStr = malloc(1);
        newStr[0] = 0;
    }

    // Genera un nuevo string tomando los caracteres del  ́ındice i al f inclusive
    // Si f>len, se tomar ́a como l ́ımite superior la longitud del string
    newStr = (f - i) >= 0 ? malloc(f - i + 1) : malloc(len_a + 1);
    int c = 0;
    while(c < len_a && c <= f)
    {
        newStr[c++] = a[i++];
    }
    newStr[c] = 0;

    // libera la memoria ocupada por la string pasada por par ́ametro.
    free(a);
    return newStr;
}

void listPrintReverse(list_t* l, FILE *pFile, funcPrint_t* fp) {
    fprintf(pFile, "[");
    if (l->last == NULL)
    {
        fprintf(pFile, "]");
        return;
    }

    listElem_t* actual = l->last;
    do
    {
        if (fp == NULL)
        {
            fprintf(pFile, "%p", actual->data);    
        } else
        {
            fp(actual->data, pFile);
        }
        actual = actual->prev;
        if (actual != NULL) fprintf(pFile, ",");
    } while (actual != NULL);
    fprintf(pFile, "]");
}

/** n3tree **/

void n3treePrintAux(n3treeElem_t* t, FILE *pFile, funcPrint_t* fp) {
    if (t == NULL) return;

    //left
    n3treePrintAux(t->left, pFile, fp);
    //center
    fprintf(pFile, "%s", t->data);
    listPrint(t->center, pFile, fp);
    fprintf(pFile, ",");
    //right
    n3treePrintAux(t->right, pFile, fp);
    

}

void n3treePrint(n3tree_t* t, FILE *pFile, funcPrint_t* fp) {
    fprintf(pFile, "<< ");
    n3treePrintAux(t->first, pFile, fp);
    fprintf(pFile, " >>");
}

/** nTable **/

void nTableRemoveAll(nTable_t* t, void* data, funcCmp_t* fc, funcDelete_t* fd) {
    int table_size = t->size;
    for (int i = 0; i < table_size; ++i)
    {
        listRemove((list_t*) &t[i], data, fc, fd);
    }
}

void nTablePrint(nTable_t* t, FILE *pFile, funcPrint_t* fp) {
    int table_size = t->size;
    for (int i = 0; i < table_size; ++i)
    {
        fprintf(pFile, "%d = ", i);
        listPrint((list_t*) &t[i], pFile, fp);
    }
}
