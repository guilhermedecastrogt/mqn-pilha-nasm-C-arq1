//Fábio Miranda, Guilherme de Castro e Danilo Arantes
//Fábio Miranda, Guilherme de Castro e Danilo Arantes
//Fábio Miranda, Guilherme de Castro e Danilo Arantes



#include <stdio.h>
#include <stdint.h>

extern int8_t codigo[];
extern int16_t regs[];
extern void executa();

extern uint8_t zero, negativo, carry;

int main() {
    char buffer[20000];
    int i = 0, j = 0;
    int8_t aux;

    printf("Digite o código de máquina (duas letras por byte em maiúsculo):\n");
    scanf("%s", buffer);

    while (buffer[i] != 0) {
        aux = buffer[i++] < 'A' ? buffer[i - 1] - '0' : buffer[i - 1] - 'A' + 10;
        aux = aux * 16 + (buffer[i] < 'A' ? buffer[i++] - '0' : buffer[i++] - 'A' + 10);
        codigo[j++] = aux;
    }

    printf("Chamando módulo CPU...\n");
    executa();

    printf("\nRetornando ao programa principal\n");
    printf("-----------------------------------------\n");
    printf("Registradores:\n");

    for (int k = 0; k < 4; k++) {
        printf("R%d -> Signed: %d | Unsigned: %u | Hex: 0x%04X\n", 
               k, (int16_t)regs[k], (uint16_t)regs[k], (uint16_t)regs[k]);
    }

    printf("\nFlags:\n");
    printf("Zero: %d | Negativo: %d | Carry: %d\n", zero, negativo, carry);
    printf("-----------------------------------------\n");

    return 0;
}
