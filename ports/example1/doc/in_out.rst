.. _Portos_exemplo1:

Transparente
************

Neste exemplo são utilizados um porto de entrada e um porto de saída,
ambos de 8 *bits*, representados na :numref:`p16_input_output_port`.
Como estão ligados na parte baixa do barramento de dados (D0-D7),
ambos os portos são acessíveis com endereços pares.
A seleção destes portos depende dos sinal A8 a A15,
situando-os na gama de endereços entre `0xcc00` e `0xccff`.

.. figure:: p16_input_output_port.png
   :name: p16_input_output_port
   :align: center

   Porto de entrada e porto de saída de 8 *bits*

O programa principal (:numref:`in_out`) recolhe os dados presentes no porto de entrada
(linha 8) e em seguida escreve-os no porto de saída (linha 9).
Esta sequência é executada continuamente, criando a aparência
de que o porto de saída está ligado diretamente ao porto de entrada.

.. code-block:: asm
   :linenos:
   :caption: Programa principal
   :name: in_out

   	.equ	PORT_ADDRESS, 0xcc00

   	.text
   main:
   	mov	r1, PORT_ADDRESS & 0xff
   	movt	r1, PORT_ADDRESS >> 8
   while:
   	ldrb	r0,[r1]
   	strb	r0,[r1]
	b	while

A instrução ``ldrb r0,[r1]`` recolhe os dados presentes no porto de entrada
para a parte baixa do registo R0.
Na fase de execução desta instrução, o processador coloca o endereço 0xcc00
no barramento de endereços (A0-15) e ativa o sinal nRD.
Em consequência o *buffer tri-state* (:numref:`p16_input_output_port`)
transfere os dados presentes nas entradas I0-7
para a parte baixa do barramento de dados (D0-7).
Por sua vez, o processador encaminha esses dados para o registo R0.

A instrução ``strb r0,[r1]`` copia os dados presentes na parte baixa de R0
para o porto de saída.
Ao executar esta instrução, o processador coloca
o endereço 0xcc00 no barramento de endereços (A0-15) e ativa o sinal nWRL.
Esta configuração coloca a zero a entrada CLK do registo (pino 11)
(:numref:`p16_input_output_port`).
A desativação do sinal nWRL provoca uma transição ascendente
que retem os dados presentes na parte baixa do barramento de dados (D0-7).
Estes dados correspondem à parte baixa de R0.

A sequência ::

 mov	r1, PORT_ADDRESS & 0xff
 movt	r1, PORT_ADDRESS >> 8

carrega o endereço do porto no registo R1.

Esta sequência de instuções (`mov` - `movt`) forma um padrão de programação para
carregamento em registo de qualquer valor numérico representado a 16 *bits*.
Este valor numérico deve ser o resultado de um expressão, determinável em
tempo de compilação, que não dependa de uma *label*.

A expressão ``PORT_ADDRESS & 0xff`` é usada para garantir que o valor do segundo
parâmetro da instrução ``mov`` é inferior a 0x100
-- que corresponde à gama de valores codifiáveis na instrução ``mov``.

A expressão ``PORT_ADDRESS >> 8`` é usada para extrair a componente de maior peso
do endereço do porto. Se o endereços for inferior a 0x100 o valor desta expressão é zero.

Neste exemplo, ``PORT_ADDRESS`` é equivalente a ``0xcc00``.
Para utilizar os portos internos do SDP16,
``PORT_ADDRESS`` deve ser equivalente a um valor par, entre ``0xff00`` e ``0xff3e``.

**Código fonte:** :download:`in_out.s<../code/in_out.s>`

**Logisim:**
   - Cicuito: :download:`p16_input_output_port.circ<../logisim/p16_input_output_port.circ>`
   - *Screenshot*: :download:`Screenshot_Logisim<../logisim/Screenshot_Logisim.png>`
   - Compilação:

   .. code-block:: console

      pas in_out.s -f logisim -l 2

**Exercícios:**

1. Testar este programa no SDP16, utilizando os portos internos.
