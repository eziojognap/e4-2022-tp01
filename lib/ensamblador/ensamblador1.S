/**
 * Referencias importantes:
 * https://developer.arm.com/documentation/dui0552/a
 * https://github.com/ARM-software/abi-aa/tree/main/aapcs32
 */
.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm

.macro endfun nombre
    .size \nombre, . - \nombre
.endm

defun copiaMemoria
    // Implementación aquí
    // R0: origen, R1: destino, R2: longitud
    //Dadas dos regiones de memoria contigua, no necesariamente alineadas y de 
    //longitud bytes (1 byte cada una) de extensión denominadas origen y destino.
    //La ruti na copiaMemoria debe copiar longitud bytes de la región origen a la región destino.
   
inicio:
    cbz R2, retornar    //cbz verifica si el registro es =0, si se cumple entonces salta a la etiqueta indicada
                        // si no se cumple continua con el programa
   
    // entonces con esta condicion comparo si hay algo en el registro que copiar,
    // si no hay nada salto a la etiqueta retornar: y vuelvo al programa
    ldrb R3,[R0],#1     // Guardo en R3(desocupado) lo que hay en el Registro origen R0
    strb R3,[R1],#1     // Guardo lo que hay en el registro R3 en la direccion de memoria de R1+1 byte (que es el registro destino)

    subs R2,R2,#1       // Resta R2-1 y lo guarda en el registro R2, por el sufijo S la bandera se ve afectada.
                        
    bne inicio          // si la resta no dio 0 entonces vuelve a comenzar
                        // si la resta dio 0 entonces sigue y retorna el programa
retornar:
    bx lr   // Es un salto indirecto, salta al registro LR

endfun copiaMemoria

defun copiaCadena
    // Implementación aquí
    // R0: origen, R1: destino, R2: longitudMaxima


    // Dada una cadena ASCIIZ de origen y una región de memoria de
    // destino con longitud suficiente para acomodarla, la rutina copiaCadena debe copiar la cadena ASCIIZ
    // en la región destino. No alterará los bytes de la región de destino que no fueron ocupados al copiar la cadena

    //Dada una cadena ASCIIZ de origen y una región de memoria de destino con 
    //longitud (especificada en longitudMaxima) l que no es suficiente para acomodarla, entonces la rutina 
    //copiaCadena debe copiar l−1 caracteres en la región de destino seguidos de un terminador nulo

        push {R4}   // saco el dato a la pila para poder utilizar el registro
        mov R4, #1   // inicializo el contador

    inicio_copia_cadena:

        cbz R2, retornar_copia_cadena

        ldrb R3, [R0],#1    // voy trayendo los datos de la memoria a los registros
        strb R3, [R1],#1    // guardo el dato en el registro en la memoria
        
        add R4, R4, #1 
        
        cmp R3, #0x00
        beq retornar_copia_cadena
        
        cmp R4, R2
        bne inicio_copia_cadena
              
        mov R3, #0x00
        strb R3, [R1]

    retornar_copia_cadena:
        pop {R4}
        bx lr
endfun copiaCadena

defun mayusculaEnLugar
    /*  
        Dada una cadena ASCIIZ correctamente terminada y ubicada en una región de longitud suficiente para contenerla,
    la rutina mayusculaEnLugar debe recorrer la cadena y sobreescribir los valores correspondientes a letras minúsculas
    en código ASCII por los valores de las correspondientes letras mayúsculas.

        Dada una cadena ASCII sin el terminador nulo, mayusculaEnLugar procede como en el caso anterior pero se detiene
    al llegar al límite de la región de memoria especificado en longitudMaxima.*/

    // Implementación aquí
    // R0: cadena, R1: longitudMaxima
    
    // inicializo un contador
    mov     R3, #0  
    cbz     R1, Retornar_mayusculas

    inicio_mayus:
        // traigo la cadena de la memoria al registro
        ldrb    R2, [R0]

        // comparo la cadena con el terminador nulo
        cmp     R2, #0x00   
        beq     Retornar_mayusculas     // si es igual salta a finalizar la funcion

        // comparo la longitud de la cadena con la longitud maxima
        cmp     R3, R1
        beq     Retornar_mayusculas

        // incremento el contador
        add     R3, R3, #1

        // Es mayuscula? comparo con Z mayuscula
        cmp     R2, 'Z'
        bhs     Minus       // si es mayor que 90 no es mayuscula, salto a minuscula

    Mayus:
        strb    R2, [R0] ,#1        // lo guardo en el registro
        b   inicio_mayus    // retorno al inicio de la funcion

    Minus:
        cmp     R2, 'a' // comparo con 'A' para ver si es una letra
        blo     Mayus // significa que no es un valor de letra en el codigo ascii y salto a Mayus que guarda el valor en memoria
        add     R2, R2, #-32         // Le sumo 32, ya que la diferencia entre minuscula y mayusculas en ascii son 32 numeros
        strb    R2, [R0] ,#1       // lo guardo en el registro
        b       inicio_mayus    // retorno al inicio de la funcion

    Retornar_mayusculas:
        bx lr
endfun mayusculaEnLugar

defun minusculaEnLugar
    /*
        Dada una cadena ASCIIZ correctamente terminada y ubicada en una región de longitud suficiente para contenerla,
    la rutina minusculaEnLugar debe recorrer la cadena y sobreescribir los valores correspondientes a letras mayúsculas
    en código ASCII por los valores de las correspondientes letras minúsculas.

        Dada una cadena ASCII sin el terminador nulo, minusculaEnLugar procede como en el caso anterior pero se detiene
    al llegar al límite de la región de memoria especificado en longitudMaxima.
    */
    
    // Implementación aquí
    // R0: cadena, R1: longitudMaxima
    
    // inicializo un contador
    mov     R3, #0  
    cbz     R1, Retornar_Minus

    inicio_minus:
        // traigo la cadena de la memoria al registro
        ldrb    R2, [R0]

        // comparo la cadena con el terminador nulo
        cmp     R2, #0x00   
        beq     Retornar_Minus     // si es igual salta a finalizar la funcion

        // comparo la longitud de la cadena con la longitud maxima
        cmp     R3, R1
        beq     Retornar_Minus

        // incremento el contador
        add     R3, R3, #1

        // Es minuscula? comparo con 'a' minuscula
        cmp     R2, 'a'
        blo     Mayus_m     // si es menor que 97 no es minuscula, salto a mayuscula


    Minus_m:
        strb    R2, [R0], #1        // lo guardo en el registro
        b   inicio_minus    // retorno al inicio de la funcion

    Mayus_m:
        cmp     R2, 'A' // comparo con 'A' para ver si es una letra
        blo     Minus_m // significa que no es un valor de letra en el codigo ascii y salgo a minus que guarda el valor en la memoria
        add     R2, R2, #32        // Le resto 32, ya que la diferencia entre minuscula y mayusculas en ascii son 32 numeros
        strb    R2, [R0] , #1       // lo guardo en el registro
        b       inicio_minus    // retorno al inicio de la funcion

    Retornar_Minus:
        bx lr
endfun minusculaEnLugar