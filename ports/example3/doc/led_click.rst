.. _Portos_exemplo3:

LED com botão
*************

Neste exemplo mostra-se como controlar o estado de um LED
-- aceso ou agado -- através de um botão de pressão.
Cada pressão no botão inverte o estado do LED:
se está apagado, acende; se está aceso, apaga.

É utilizando o mesmo *hardware* do exemplo da :numref:`Portos_exemplo2`.

Para realizar esta operação é necessário detetar a alteração de estado do botão.
Não basta verificar se o botão está premido.
Para isso são realizados dois ciclos,
um retém o processamento enquanto o botão não estiver premido (linhas 5 e 6)
e o outro retém o processamento enquanto o botão estiver premido (linhas 11 e 12).
A passagem do primeiro ciclo para o segundo,
acompanha a alteração de estado do botão de "não premido" para "premido".
Nessa altura inverte-se a representação de estado do LED,
na variável ``led_state`` (linha 8),
e em seguida atualiza-se o porto de saída (linha 9).

.. literalinclude:: ../code/led_click.s
   :language: c
   :linenos:
   :caption: Programa principal
   :name: led_click
   :lines: 31-43

Na tradução do programa para linguagem *assembly* (:numref:`led_click_asm`),
as funções ``inport_read`` e ``outport_write`` são implementadas como rotinas.
Esta solução permite um melhor arranjo do código, isolando nestas rotinas os detalhes
relacionados com o *hardware*.
Ao nível do programa principal, o acesso aos portos é realizado por invocação
destas rotinas (linhas 4, 7, 15 e 17)
e cumprindo o protocolo convencionado de passagem de argumentos e retorno de valores.

.. literalinclude:: ../code/led_click.s
   :language: asm
   :linenos:
   :caption: Programa principal em linguagem *assembly*
   :name: led_click_asm
   :lines: 48-68

A função ``inport_read`` devolve os dados que se apresentam à entrada do porto.
O endereço do porto, representado pelo símbolo ``INPORT_ADDRESS``,
é carregado em R0 (linhas 3 e 4); a instrução ``ldrb r0, [r0, #1]``
transfere o valor presente nesse momento à entrada do porto para R0,
por ser o registo convencionado para o retorno de valores de funções.

.. literalinclude:: ../code/led_click.s
   :language: asm
   :linenos:
   :caption: Função ``inport_read``
   :name: inport_read_func
   :lines: 71, 75-79

A função ``outport_write`` escreve os dados que recebe em parâmetro
no porto de saída. O endereço do porto, é carregado em R1 (linhas 3 e 4),
porque R0 contém o argumento da função; a instrução ``strb r0, [r1, #1]``
transfere a parte baixa de R0 para o registo do porto.

.. literalinclude:: ../code/led_click.s
   :language: asm
   :linenos:
   :caption: Função ``outport_write``
   :name: outport_write_func_impar
   :lines: 82, 86-90

Relativamente à solução usada no exemplo da :numref:`Portos_exemplo2`,
em que a tradução para *assembly* destas funções foi feita por subtituição direta
(*inline*), esta solução tem a desvantagem de executar mais instruções por cada acesso a porto
-- a instrução `bl` para invocação e a instrução `mov pc, lr` para retorno.


**Código fonte:** :download:`led_click.s<../code/led_click.s>`

**Teste em Logisim:**
   - Cicuito: :download:`p16_led_button.circ<../../example2/logisim/p16_led_button.circ>`
   - *Screenshot*: :download:`Screenshot_Logisim<../../example2/logisim/Screenshot_Logisim.png>`
   - Compilação:

   .. code-block:: console

      p16as led_click.s -f logisim -l 2

**Teste no P16 Simulator:**
   - Ficheiro de configuração do p16sim: :download:`p16sim_config_ports_ex3.txt<../p16sim/p16sim_config_ports_ex3.txt>`
   - Compilação do programa:

   .. code-block:: console

      p16as led_click.s

   - Invocação do simulador:

   .. code-block:: console

      p16sim -c p16sim_config_ports_ex3.txt
      
**Exercícios:**

1. Mantendo o mesmo funcionamento, modificar a programação anterior
   de modo a realizar a deteção das mudanças de estado do botão de pressão
   sem usar o método dos ciclos de espera das
   linhas 5 e 6 e linhas 9 e 10, da :numref:`led_click`.
   Sugestão: em cada iteração testar o estado anterior e o estado atual do botão.

2. Transformar o programa anterior num programa que conte e apresente no porto de saída,
   a contagem do número de vezes que o botão de pressão foi premido.
