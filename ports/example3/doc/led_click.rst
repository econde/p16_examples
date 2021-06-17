.. _Portos_exemplo3:

LED com botão
*************

Neste exemplo mostra-se como controlar o estado de um LED
-- aceso ou agado -- através de um botão de pressão.
Cada pressão no botão inverte o estado do LED:
se estava apagado, acende; se estava aceso, apaga.

É utilizando o mesmo *hardware* do exemplo da :numref:`Portos_exemplo2`.

Para realizar esta operação é necessário detetar a alteração de estado do botão.
Não basta verificar se o botão está premido.
Para isso são realizados dois ciclos,
um retém o processamento enquanto o botão não está premido (linhas 5 e 6)
e o outro retém o processamento enquanto o botão está premido (linhas 9 e 10).
A passagem do primeiro ciclo para o segundo,
acontece quando o botão é premido.
Nessa altura inverte-se a representação de estado do LED,
na variável ``led_state`` (linha 7),
e em seguida atualiza-se o porto de saída (linha 8).

 .. code-block:: c
   :linenos:
   :caption: Programa principal
   :name: led_click

   void main() {
   	uint8_t led_state = 0;
   	port_output(led_state);
   	while (1) {
   		while ((port_input() & BUTTON_MASK) != 0)
   			;

   		led_state = ~led_state;

   		port_output(led_state & LAMP_MASK);
   		while ((port_input() & BUTTON_MASK) == 0)
   			;
   	}
   }

Na tradução do programa para linguagem *assembly* (:numref:`led_click_asm`),
as funções ``port_input`` e ``port_output`` são implementadas como rotinas.
Esta solução permite um melhor arranjo do código, isolando nas rotinas os detalhes
relacionados com o *hardware*.
Ao nível do programa principal, o acesso aos portos é realizado por invocação
destas rotinas (linhas 5, 8, 16 e 18)
e cumprindo o protocolo convencionado de passagem de argumentos e retorno de valores.

.. code-block:: asm
   :linenos:
   :caption: Programa principal em linguagem *assembly*
   :name: led_click_asm

   	.text
   main:
   	mov	r4, 0		; uint8_t led_state = 0;
   	mov	r0, r4		; port_output(led_state);
   	bl	port_output
   while:
   while1:
   	bl	port_input	; while ((port_input() & BUTTON_MASK) == 0)
   	mov	r1, BUTTON_MASK		;
   	and	r0, r0, r1
   	bzc	while1

   	not	r4, r4		; led_state = ~led_state;
   	mov	r0, LED_MASK
   	and	r0, r0, r4
   	bl	port_output	; port_output(led_state & LED_MASK);
   while2:
   	bl	port_input	; while ((port_input() & BUTTON_MASK) != 0)
   	mov	r1, BUTTON_MASK		;
   	and	r0, r0, r1
   	bzs	while2
   	b	while

A função ``uint8_t port_input()`` devolve os dados que se apresentam à entrada do porto.
O endereço do porto, representado pelo símbolo ``PORT_ADDRESS``,
é carregado em R0 (linhas 2 e 3); a instrução ``ldrb r0, [r0, 1]``
transfere o valor presente nesse momento à entrada do porto para R0,
por ser o registo convencionado para o retorno de valores de funções.

.. code-block:: asm
   :linenos:
   :caption: Função ``port_input``
   :name: port_input_func

   port_input:
   	mov	r0, PORT_ADDRESS & 0xff
   	movt	r0, PORT_ADDRESS >> 8
   	ldrb	r0, [r0, 1]
   	mov	pc, lr

A função ``void port_output(uint8_t)`` escreve os dados que recebe em parâmetro
no porto de saída.

.. code-block:: asm
   :linenos:
   :caption: Função ``port_output``
   :name: port_output_func

   port_output:
   	mov	r1, PORT_ADDRESS & 0xff
   	movt	r1, PORT_ADDRESS >> 8
   	strb	r0, [r1, 1]
   	mov	pc, lr

Relativamente à solução usada no exemplo da :numref:`Portos_exemplo2`,
em que a tradução para *assembly* destas funções foi por subtituição direta
(*inline*), esta solução tem a desvantagem de executar mais instruções.
Pelo menos, a instrução `bl` para invocação e a instrução `mov pc, lr` para retorno.


**Código fonte:** :download:`led_click.s<../code/led_click.s>`

**Logisim:**
   - Cicuito: :download:`p16_led_button.circ<../../example2/logisim/p16_led_button.circ>`
   - *Screenshot*: :download:`Screenshot_Logisim<../../example2/logisim/Screenshot_Logisim.png>`
   - Compilação:

   .. code-block:: console

      pas led_click.s -f logisim -l 2

**Exercícios:**

1. Mantendo o mesmo funcionamento, modificar a programação anterior
   de modo a realizar a deteção das mudanças de estado do botão de pressão
   sem usar o método dos ciclos de espera das
   linhas 5 e 6 e linhas 9 e 10, da :numref:`led_click`.

2. Transformar o programa anterior num programa que conte e apresente no porto de saída,
   a contagem do número de vezes que o botão de pressão foi premido.

