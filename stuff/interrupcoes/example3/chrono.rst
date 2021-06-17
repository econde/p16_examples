Exemplo 2 - Cronómetro
**********************

Neste exercício propõe-se a realização de um cronómetro de segundos,
em contagem descendente. A contagem começa com um valor pré-definido,
termina em zero e é iniciada ou reiniciada sempre que o botão é premido.
O valor corrente do cronómetro é visualizado
num mostrador formado por um dígito de sete segmentos,
ligado directamente no porto de saída.
O estado do botão é recolhido num bit do porto de entrada.
Como solução para eliminação do pedido de interrupção – clear do flip-flop
– é utilizado um bit do porto de saída.
Esta solução implica a necessidade de incluir programação específica na ISR,
para realizar esta operação.


figura com SDP16 com display de 7 segmentos


No programa principal começa-se por afixar o valor zero no mostrador,
ao que se segue o ciclo infinito de detecções de pressão no botão.
Admitindo que a pressão do botão provoca a ida do sinal de entrada para o valor lógico um,
o programa transita da linha 9 para a linha 15.
Neste trânsito, são realizadas as acções necessárias para desencadear uma contagem,
designadamente:

    • linha 11 – iniciar o contador de tempo (variável time);
    • linha 12 – afixar o valor inicial no mostrador;
    • linha 13 – eliminar eventual pedido de interrupção devido a transição de relógio anterior;
    • linha 14 – permitir a aceitação das interrupções que farão evoluir a contagem.
Admitindo que a frequência do relógio aplicado à entrada de interrupção é de 1 Hz,
a ISR será invocada de um em um segundo.
No início do processamento da ISR, começa-se por decrementar o contador de tempo
e verificar se atingiu o valor final – zero.
Em caso afirmativo, inibe-se a aceitação de interrupções através da função interrupt_clear.
Até haver nova pressão no botão e ser executada a acção interrupt_enable
não haverá mais interrupções e o valor zero permanecerá afixado no mostrador,
A função display_write, invocada na linha 23,
atualiza o mostrador com o valor atual do contador de tempo.
A função interrupt_clear, invocada nas linhas 13 e 24,
elimina o pedido de interrupção presente no flip-flop,
pulsando a zero o bit do porto de saída ligado à entrada CLR do flip-flop.

.. code-block:: c
   :linenos:

   #define	TIME_MAX	9
   #define	BUTTON_MASK	1

   uint8_t time;

   void main() {
   	display_write(0);
   	while (1) {
   		while ((port_input() & BUTTON_MASK) == 0)
   			;
   		time = TIME_MAX;
   		display_write(time);
   		interrupt_clear();
   		interrupt_enable();
   		while ((port_input() & BUTTON_MASK) != 0)
   			;
   	}
   }

   void isr() {
   	if (--time == 0)
   		interrupt_disable();
   	display_write(time);
   	interrupt_clear();
   }

   uint8_t port_image;

   #define DISPLAY_MASK	0x7f

   const uint8_t bin7seg[] =
   	{0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f};

   void display_write(uint8_t value) {
   	port_image &= ~DISPLAY_MASK;
   	port_image |= bin7seg[value];
   	port_output(port_image);
   }

   #define CLEAR_MASK	0x80

   void interrupt_clear() {
   	port_output(port_image & ~CLEAR_MASK);
   	port_output(port_image | CLEAR_MASK);
   }

Como o acesso ao porto de saída implica a escrita simultânea dos 8 bits
 – unidade mínima de endereçamento no P16
 – coloca-se o problema de atualizar o mostrador sem fazer clear ao flip-flop ou o de fazer clear ao flip-flop sem perturbar a imagem no mostrador.
Numa situação simples como a deste exemplo,
em que ambas as operações são realizadas no contexto da ISR,
o problema resolve-se facilmente reunindo os dados a escrever no mostrador
mais o comando do flip-flop.
Com o objetivo de executar estas operações em contextos independentes,
a programação das funções display_write
e interrupt_clear deve integrar a solução deste problema.
Para que num dado contexto, se possa manter o estado do porto de saída,
relativo a outros contextos, deve-se conhecer esse estado.
Por exemplo, para que ao fazer clear ao flip-flop,
não se altere o mostrador é necessário conhecer o que este tem afixado
para tornar a escrever o mesmo valor.
Como não é possível ler de um porto de saída
– a não ser que este esteja ligado a um porto de entrada
– na implementação destas funções recorre-se
à utilização da variável port_image para guardar o valor atual do porto de saída.
Cada função modifica apenas o seu conjunto de bits e mantém os restantes.
Sendo a atualização do porto de saída, acompanhada da atualização desta variável.


Programa em Assembly

Por razões de estruturação do programa, são formalizadas as funções auxiliares:
    • port_output – para escrever no porto da saída;
    • port_input – para ler do porto de entrada;
    • interrupt_enable – para permitir a aceitação de interrupções por parte do processador;
    • interrupt_disable – para inibir a aceitação de interrupções por parte do processador;
    • interrupt_clear – para eliminar do pedido de interrupção;
    • display_write – para afixar valores no mostrador.
Na tradução para linguagem assembly as quatro primeiras dão origem a sequências de instruções que traduzem diretamente as suas ações (tradução inline). As duas últimas, display_write e interrupt_clear, são formalmente  implementadas como rotinas assembly.
A função interrupt_disable é traduzida pelas instruções
	mrs	r0, spsr
	mov	r1, ~IFLAG_MASK
	and	r0, r0, r1
	msr	spsr, r0

Como é executada no contexto da ISR, atua sobre o registo SPSR,
que é a cópia do CPSR do programa interrompido. Ao terminar a ISR,
a instrução movs pc, lr copia o conteúdo de SPSR para CPSR
colocando a flag I a zero e assim inibindo a aceitação de novas interrupções.
Na eventualidade de ser necessário implementar esta função
no contexto do programa principal esta deverá atuar diretamente sobre o registo CPSR.
Os conteúdos de R0, R1, R2, R3 e LR  são salvaguardados no início da ISR,
nas linhas 35 a 39, porque no corpo da ISR irão ser invocadas outras funções.
Segundo o protocolo de chamada a funções,
os registos R0 a R3 são utilizados para passagem de argumentos
e podem ser alterados pela função chamada,
os restantes registos são salvaguardados pela função chamada,
caso venham a ser utilizados, dispensando a sua salvaguarda na ISR.
O registo LR é modificado pela própria instrução BL,
por isso também tem que ser salvaguardado.
Se a própria função ISR utilizar algum registo de ordem superior a R3,
terá ela própria que o salvaguardar.
No presente exercício é omitida a secção .startup
por ter um conteúdo igual à do exemplo anterior.

.. code-block:: guess
   :linenos:

	.equ	TIME_MAX, 9
	.equ	BUTTON_MASK, 1
	.equ	IFLAG_MASK, 0x10

	.data
time:
	.byte	0	; uint_t time = 0;

	.text
main:
	mov	r0, 0
	bl	display_write
while:					; while (1) {
while1:					; while ((
	ldr	r1, addr_port		;	port_input()
	ldrb	r0, [r1]
	mov	r2, BUTTON_MASK
	and	r0, r0, r2			;	 & BUTTON_MASK)
	bzs	while1			;		== 0)
	mov	r0, TIME_MAX		; time = TIME_MAX;
	ldr	r1, addr_time
	strb	r0, [r1]
	bl	display_write
	bl	interrupt_clear
	mov	r0, IFLAG_MASK		; interrupt_enable();
	msr	cpsr, r0
while2:					; while ((
	ldr	r1, addr_port		;	port_input()
	ldrb	r0, [r1]
	mov	r2, BUTTON_MASK
	and	r0, r0, r2			;	 & BUTTON_MASK)
	bzc	while2			;	 	!= 0)
	b	while

/*------------------------------------------------------------------------
*/
	.text
isr:
	push	r0
	push	r1
	push	r2
	push	r3
	push	lr

	ldr	r1, addr_time		; if (--time == 0)
	ldrb	r0, [r1]
	sub	r0, r0, 1
	strb	r0, [r1]
	bzc	isr_if_end
	mrs	r2, spsr			; interrupt_disable();
	mov	r1, ~IFLAG_MASK
	and	r2, r2, r1
	msr	spsr, r2
isr_if_end:
	bl	display_write		; display_write(time);

	bl	interrupt_clear
	pop	lr
	pop	r3
	pop	r2
	pop	r1
	pop	r0
	movs	pc, lr

addr_time:
	.word	time

/*------------------------------------------------------------------------
*/
	.data
port_image:
	.byte	0

	.equ	DISPLAY_MASK, 0x7f

	.text
display_write:
	ldr	r1, addr_port_image	; port_image &= ~DISPLAY_MASK;
	ldrb	r2, [r1]
	mov	r3, ~DISPLAY_MASK
	and	r2, r2, r3
	ldr	r3, addr_bin7seg		; port_image |= bin7seg[value];
	ldrb	r0, [r3, r0]
	or	r2, r2, r0
	strb	r2, [r1]
	ldr	r1, addr_port		; port_output(port_image);
	strb	r2, [r1]
	mov	pc, lr

bin7seg:
	.byte 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f

addr_bin7seg:
	.word 	bin7seg

/*------------------------------------------------------------------------
*/
	.equ	CLEAR_MASK, 0x80
	.text
interrupt_clear:
	ldr	r1, addr_port_image
	ldrb	r0, [r1]
	ldr	r2, addr_port
	mov	r3, ~CLEAR_MASK
	and	r3, r0, r3
	strb	r3, [r2]		; port_output(port_image & ~CLEAR_MASK);
	mov	r3, CLEAR_MASK
	or	r3, r0, r3
	strb	r3, [r2]
	strb	r3, [r1]		; port_output(port_image |= CLEAR_MASK);
	mov	pc, lr

addr_port:
	.word	0xff00

addr_port_image:
	.word	port_image





