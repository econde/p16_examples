.. _Portos_exemplo2:

LED on/off
**********

Neste exemplo, reproduz-se no LED o estado do botão de pressão:
se o botão estiver solto o LED está apagado;
se o botão estiver premido o LED está aceso.

São utilizados o porto de entrada e o porto de saída de 8 *bits* apresentados
na :numref:`p16_button_led`.
Note-se que os portos estão ligados na parte alta do barramento de dados (D8-15).

.. figure:: p16_button_led.png
   :name: p16_button_led
   :align: center

   Portos de 8 *bits* na parte alta do *data bus*

O programa da :numref:`led_button` lê continuamente o porto de entrada -- ``port_input()`` --
e testa o *bit* da posição do botão -- ``& BUTTON_MASK``.
Se o valor lógico do *bit* do botão for **zero**, significa que o botão está premido,
então escreve no porto de saída um valor com o *bit* da posição do LED a um,
para acender o LED -- ``port_output(LED_MASK)``.
Se o valor lógico do *bit* do botão for **um**, significa que o botão está solto,
então escreve o valor zero, para apagar o LED -- ``port_output(0)``.

 .. code-block:: c
   :linenos:
   :caption: Programa principal em linguagem C
   :name: led_button

   #define	BUTTON_MASK	(1 << 2)
   #define	LED_MASK	(1 << 4)

   int main() {
   	while (true) {
   		if ((port_input() & BUTTON_MASK) == 0)
   			port_output(LED_MASK);
   		else
   			port_output(0);
   	}
   }

Na tradução do programa para linguagem *assembly* (:numref:`led_button_asm`),
as funções ``port_input`` e ``port_output`` são traduzidas pelas sequências de instruções ::

   ldr  r1, addr_port
   ldrb r0, [r1, 1]

e ::

   ldr  r1, addr_port
   strb r0, [r1, 1]

respectivamente.

O endereço do porto é carregado em registo de maneira diferente da :numref:`Portos_exemplo1`.
Aqui, o endereço é carregado pela instrução ``ldr  r1, addressof_port`` (linha 9). Esta instrução
usa endereçamento relativo ao PC. A posição de memória ``addressof_port`` contém o endereço do porto
e está posicionada num endereço superior ao da instrução ``ldr``
e a uma distância inferior a 128 *bytes* (linhas 23 e 24).

 .. code-block:: asm
   :linenos:
   :caption: Programa principal em linguagem *assembly*
   :name: led_button_asm

   	.equ	BUTTON_MASK, (1 << 2)
   	.equ	LED_MASK, (1 << 4)

   	.equ	PORT_ADDRESS, 0xcc00

   	.text
   main:
   while:
   	ldr	r1, addressof_port
   	ldrb	r0, [r1, 1]
   	mov	r2, BUTTON_MASK
   	and	r0, r0, r2
   	bzc	if_else
   	mov	r0, LED_MASK
   	b	if_end
   if_else:
   	mov	r0, 0
   if_end:
   	ldr	r1, addr_port
   	strb	r0, [r1, 1]
  	b	while

   addressof_port:
   	.word	PORT_ADDRESS

O acesso aos portos de 8 *bits* na parte alta do barramento de dados (D8 a D15)
deve utilizar endereços ímpares.
Para ficar explícito na análise do programa, que se trata de um acesso a endereço ímpar,
as instruções ``ldrb r0, [r1, 1]`` (linha 10) e ``strb r0, [r1, 1]`` (linha 20)
recebem na primeira componente de formação do endereço (registo R1) um valor par,
e na segunda componente o valor 1 -- resultando num endereço ímpar.

O símbolo ``BUTTON_MASK`` é equivalente ao valor binário ``0000 0100``
e o símbolo LED_MASK é equivalente a ``0001 0000``.
Os uns coincidem com as posições dos portos onde o botão e o LED estão ligados.

O teste do estado do botão é realizado nas linhas 12 e 13.
Se o botão estiver premido,
o valor do *bit* de R0 que lhe corresponde é zero,
o que faz com que o resultado da operação AND seja zero, e a *flag* Z seja afetada com um.
A instrução ``bzc if_else`` deixa avançar o processamento para a linha 14,
onde R0 recebe o valor do símbolo LED_MASK.

Se o botão não estiver premido,
o valor do *bit* de R0 que lhe corresponde é um, devido à resistência *pull-up*,
o que faz com que o resultado da operação AND seja diferente de zero,
e a *flag* Z seja afetada com zero.
A instrução ``bzc if_else`` direciona a execução do programa para o ramo *else* do *if*,
onde se coloca o valor zero em R0 (linha 17).

No final (linhas 19 e 20) o estado do LED é atualizado
com o valor lógico previamente colocado em R0.

**Código fonte:** :download:`led_button.s<../code/led_button.s>`

**Logisim:**
   - Cicuito: :download:`p16_led_button.circ<../logisim/p16_led_button.circ>`
   - *Screenshot*: :download:`Screenshot_Logisim<../logisim/Screenshot_Logisim.png>`
   - Compilação:

   .. code-block:: console

      pas led_button.s -f logisim -l 2

**Exercícios:**

1. Modificar a programação anterior de modo a realizar o mesmo objetivo
   (reproduzir o estado do botão no LED), mas sem usar *if*, ou seja, sem usar instruções *branch* ao nível do *assembly*.

2. Implementar como rotinas *assembly* as funções de leitura e de escrita nos portos ``port_input`` e ``port_output``.
