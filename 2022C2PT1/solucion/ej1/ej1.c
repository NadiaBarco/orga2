#include "ej1.h"

char** agrupar_c(msg_t* msgArr, size_t msgArr_len){
    
    size_t i=0;
    char** res=(char**)malloc(MAX_TAGS*8);
    while(i<msgArr_len){
        if(msgArr->tag==0){
            strcat(res[0],msgArr->text);
        }
        else if(msgArr->tag==1){
            strcat(res[1],msgArr->text);
        }
        else if (msgArr->tag==2)
        {
            strcat(res[2],msgArr->text);
        }else if (msgArr->tag==3)
        {
            strcat(res[3],msgArr->text);
        }
        
    }
    return res;
}
