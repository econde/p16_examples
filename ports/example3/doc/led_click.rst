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
e o outro retém o processamento enquanto o botão está premido (linhas 11 e 12).
A passagem do primeiro ciclo para o segundo,
acontece quando o botão é premido.
Nessa altura inverte-se a representação de estado do LED,
na variável ``led_state`` (linha 8),
e em seguida atualiza-se o porto de saída (linha 9).

.. literalinclude:: ../code/led_click.s
   :language: c
   :linenos:
   :caption: Programa principal
   :name: led_click
   :lines: 27-40

Na tradução do programa para linguagem *assembly* (:numref:`led_click_asm`),
as funções ``port_input`` e ``port_output`` são implementadas como rotinas.
Esta solução permite um melhor arranjo do código, isolando nas rotinas os detalhes
relacionados com o *hardware*.
Ao nível do programa principal, o acesso aos portos é realizado por invocação
destas rotinas (linhas 5, 8, 16 e 18)
e cumprindo o protocolo convencionado de passagem de argumentos e retorno de valores.

.. literalinclude:: ../code/led_click.s
   :language: asm
   :linenos:
   :caption: Programa principal em linguagem *assembly*
   :name: led_click_asm
   :lines: 43-64

A função ``port_input`` devolve os dados que se apresentam à entrada do porto.
O endereço do porto, representado pelo símbolo ``PORT_ADDRESS``,
é carregado em R0 (linhas 4 e 5); a instrução ``ldrb r0, [r0, 1]``
transfere o valor presente nesse momento à entrada do porto para R0,
por ser o registo convencionado para o retorno de valores de funções.

.. literalinclude:: ../code/led_click.s
   :language: asm
   :linenos:
   :caption: Função ``port_input``
   :name: port_input_func
   :lines: 67, 70-75

A função ``port_output`` escreve os dados que recebe em parâmetro
no porto de saída. O endereço do porto, é carregado em R1 (linhas 4 e 5),
porque R0 contém o argumento da função; a instrução ``strb r0, [r1, 1]``
transfere a parte baixa de R0 para o registo do porto.

.. literalinclude:: ../code/led_click.s
   :language: asm
   :linenos:
   :caption: Função ``port_output``
   :name: port_output_func_impar
   :lines: 78, 80-85

Relativamente à solução usada no exemplo da :numref:`Portos_exemplo2`,
em que a tradução para *assembly* destas funções foi por subtituição direta
(*inline*), esta solução tem a desvantagem de executar mais instruções por cada acesso a porto
-- a instrução `bl` para invocação e a instrução `mov pc, lr` para retorno.


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

