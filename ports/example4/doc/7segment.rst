.. _Portos_exemplo4:

Contador
********

Neste exemplo, mostra-se como detetar transições em vários *bits* de um porto
de entrada, como manipular *bits* de um mesmo porto de saída, em diferentes contextos,
e como utilizar um *display* de sete segmentos.

No *display* apresenta-se um contador que evolui uma unidade por cada pressão no botão **Clock**.
O *display* é atualizado sempre que o valor do contador é alterado.
A pressão do botão **Up/Down** inverte o sentido de contagem -- crescente ou decrescente.
O sentido de contagem é indicado no LED: aceso -- contagem crescente;
apagado -- contagem decrescente.

.. figure:: p16_7segment.png
   :name: p16_7segment
   :align: center

   Porto de entrada com botões e porto de saída com *display* de sete segmentos

Na :numref:`counter_7segment` é apresentada uma solução de programação para a situação
enunciada.

A variável ``counter`` representa o contador, que evolui na gama de valores 0 a 9.

A variável `direction_state` representa o sentido de contagem do contador.
O seu valor é invertido em cada pressão do botão Up/Down
e é testado em cada pressão do botão Clock, para evoluir o contador no sentido correto.

A variável `port_prev` representa o valor lido anteriormente do porto de entrada.
Ao ser comparada com o valor atual do porto de entrada permite
detetar alterações no estado dos botões.

Como um botão premido impõe o valor lógico zero à entrada do porto,
o valor retornado por `port_input` é imediatamente invertido
para que o código se escreva em lógica positiva, a assim facilitar a compreenção
(linhas 12 e 18).

.. code-block:: c
   :linenos:
   :caption: Programa de controlo do contador
   :name: counter_7segment

   #define	LED_MASK		(1 << 7)
   #define	DISPLAY_MASK		0x7f
   #define	BUTTON_UPDOWN_MASK	(1 << 1)
   #define	BUTTON_CLOCK_MASK	(1 << 6)

   const uint8_t bin7seg[] =
   	{0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f};

   void main() {
   	uint16_t counter;
   	uint8_t direction_state = 0;
   	uint8_t port_prev = ~port_input();

   	port_write(direction_state ? LED_MASK : 0, LED_MASK);
   	port_write(tab7seg[counter], 7SEG_MASK);

   	while (1) {
   		uint8_t port_actual = ~port_input();
   		if ((port_prev & BUTTON_UPDOWN_MASK) == 0 && (port_actual & BUTTON_UPDOWN_MASK) != 0) {
   			direction_state = ~direction_state;
   			port_write(direction_state ? LED_MASK : 0, LED_MASK);
   		}
   		if ((port_prev & BUTTON_CLOCK_MASK) == 0 && (port_actual & BUTTON_CLOCK_MASK) != 0) {
   			if (direction_state)
   				if (counter == 9)
   					counter = 0;
   				else
   					counter += 1;
   			else
   				if (counter == 0)
   					counter = 9;
   				else
   					counter -= 1;
   			port_write(tab7seg[counter], 7SEG_MASK);
   		}
   		port_prev = port_actual;
   	}
   }

Depois da inicialização (linhas 10 a 17) o programa entra num ciclo infinito
cuja atividade é dividida em duas partes:
o processamento da indicação do sentido de contagem (linhas 19 a 22)
e o processamento do contador (linhas 23 a 35).

A primeira parte consiste na deteção de pressão do botão **Up/Down** (linha 19),
inversão da variável de estado ``direction_state`` (linha 20)
e afixação do sentido de contagem no LED (linha 21).

A segunda parte consiste na deteção de pressão do botão **Clock** (linha 23),
evolução do contador de acordo com a variável ``direction_state`` (linhas 24 a 33)
e afixação do valor do contador no *display* (linha 34).

A deteção da pressão do botão consiste em verificar se o estado anterior era zero ::

   if ((port_prev & BUTTON_CLOCK_MASK) == 0

e se o estado atual é diferente de zero. ::

   (port_actual & BUTTON_CLOCK_MASK) != 0) {

A necessidade de manipular o *display*, ligado nos 7 *bits* de menor peso do porto,
e de manipular o LED, ligado no *bit* de maior peso do porto,
em contextos diferentes, levou é criação da função ``port_write``.

A utilização simples da função ``port_output`` definida na :numref:`port_output_func_par`
não é viável pois afeta todos os *bits* do porto -- ao atualizar o *display* modifica
o LED e vice-versa.

A função `'port_write`` -- :numref:`port_write` permite alterar apenas os *bits*
de algumas posições, mantendo os restantes com o mesmo valor.
Os *bits* que vão ser afetados são definidos através do parâmetro ``mask``
que contém o valor um nessas posições e zero nas restantes. Por exemplo,
para especificar as posições afetas ao *display* a máscara é 0111 1111.

A manutenção dos restantes *bits* é baseada na memorização do valor anteriormente
escrito no porto, mantido na variável local ``image`` (linha 2) da :numref:`port_write`.

.. code-block:: c
   :linenos:
   :caption: Função ``port_write``
   :name: port_write

   void port_write(uint8_t value, uint8_t mask) {
   	static uint8_t port_image;
   	port_image &= ~mask;
   	port_image |= value & mask;
   	port_output(port_image);
   }

Em linguagem C o atributo ``static`` na definição de uma variável local significa
que essa variável deve ser implementada sempre no mesmo local da memória de dados.
Não pode ser implementada em registo ou em *stack*. Assim em todas as execuções
a função irá encontrar nessa variável o valor lá deixado na execução anterior.

.. code-block:: asm
   :linenos:
   :caption: Função ``port_write`` em *assembly*
   :name: port_write_asm

   	.data
   image:
   	.byte	0

   	.text
   port_write:
   	push	lr
   	ldr	r2, addressof_image
   	ldrb	r3, [r2]
   	mvn	r1, r1
   	and	r3, r3, r1
	mvn	r1, r1
   	and	r0, r0, r1
   	orr	r0, r3, r0
   	strb	r0, [r2]
   	bl	port_output
   	pop	pc

   addressof_image:
	.word	image

.. code-block:: asm
   :linenos:
   :caption: Função ``port_output``
   :name: port_output_func_par

   ; void port_output(uint8_t);

	.equ	PORT_ADDRESS, 0xcc00

   port_output:
   	mov	r1, PORT_ADDRESS & 0xff
   	movt	r1, PORT_ADDRESS >> 8
   	strb	r0, [r1]
   	mov	pc, lr


**Código fonte:** :download:`7segment.s<../code/7segment.s>`

**Logisim:**
   - Cicuito: :download:`p16_led_button.circ<../logisim/p16_7segment.circ>`
   - *Screenshot*: :download:`Screenshot_Logisim<../logisim/Screenshot_Logisim.png>`

   .. code-block:: console

      pas 7segment.s -f logisim -l 2

**Exercícios:**

1. Aumentar o porto de saída para 16 *bits*
   e acrescentar mais um *display* de sete segmentos,
   passando a ter capacidade para afixar dois dígitos decimais.
   Adaptar o programa de modo a atualizar os dois *displays* numa única instrução **str**.
