#include <stdio.h>
#include <string.h>
typedef struct {
    char* nombre;
    __uint32_t vida;
    double ataque;
    double defensa;
} monstruo_t; 


monstruo_t monstruos[]={
    {"Monstrua A", 100, 13.5,2,8},
    {"Monstruo B",100,12,2,6},
    {"Monstrua C",100, 12.2,2.5,5}
};

void evolution(monstruo_t *monstruo){
    monstruo->ataque+=10;
    monstruo->defensa+=10;
};

void a_mayusculas(char strings[]){
    int longitud=strlen(strings);
    char nuevo_str[longitud];
    for(int i=0 ;i<longitud;i++){
        if(strings[i]>='a' && strings[i]<='z'){
            strings[i]=strings[i]-32;
        
        }
    }
}


typedef struct{
    char *nombre;
    __uint32_t edad;
} persona_t;

persona_t* crearPersona(char *nombre_p, __uint32_t edad_p){
    persona_t* create_person=malloc(sizeof(persona_t));

    if(create_person==NULL){
        return NULL;
    }
    create_person->nombre= nombre_p;
    create_person->edad=edad_p;

    return create_person;
};

void eliminarPersona(persona_t* persona){
    free(&persona);
}

int main(int argc, char const *argv[])
{
    for(__uint32_t i=0;i<3;i++){
        // es .nombre porque no es un puntero, cuando es puntero es ->
        printf("nombre: %s\n",monstruos[i].nombre);
        printf("vida: %d\n",monstruos[i].vida);
        
    }
    evolution(&monstruos[1]);

    printf("incremento ataque: %f\nincremento de defensa: %f",monstruos[1].ataque, monstruos[1].defensa);

    int x = 42;
    int *p = &x;
    printf("Direccion de x: %p Valor: %d\n", (void*) &x, x);
    printf("Direccion de p: %p Valor: %p\n", (void*) &p, (void*) p);
    printf("Valor de lo que apunta p: %d\n", *p);


    // puntero a chars(a.k.a string) es read-only
    char *str1="hola";
    // lista de chars, modificable, se suma el '/0'
    char str2[]="hola";
    printf("este un puntero a char %s\n este es una lista de chars: %s",str1,str2);
    return 0;
}
