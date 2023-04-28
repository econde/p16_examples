.. _Timers_exemplo3:

Pisca-pisca com botão
*********************

Considere-se um botão de pressão ligado num *bit* do porto de entrada
e um LED ligado num *bit* do porto de saída, conforme a :numref:`button_led`.
Pretende-se usar o botão para controlar o estado de intermitência do LED.
Uma pressão no botão inverte o funcionamento do LED:
se estava apagado passa a intermitente;
se estava intermitente passa a apagado.

Os estados naturais de um LED são apagado ou aceso.
A intermitência é realizada artificialmente por programação,
apagando e acendendo o LED a um dado ritmo.
Para o programa realizar esta tarefa é necessária de uma referência temporal.

A referência temporal utilizada é baseada no *timer* da :numref:`sdp16_timer_74590`.

O programa principal (:numref:`blink_button`) tem uma estrutura idêntica à do exemplo
da :numref:`Portos_exemplo3`.
O processamento oscila entre os dois ciclos *while* (linhas 4 a 10) acompanhando o
estado do botão de pressão. Admitindo que o botão premido impõe um valor lógico zero,
o *while* da linha 4 corresponde a botão solto e o *while* da linha 9 corresponde
a botão premido.
A passagem do processamento do *while* da linha 4 para o *while* da linha 9,
dá-se quando o botão é premido. Nessa altura inverte-se o valor lógico
da variável ``blink_state``, que representa o estado de intermitência do LED
-- em atividade de intermitência ou desligado.

.. literalinclude:: ../code/blink_button.s
   :language: c
   :linenos:
   :caption: Programa de controlo do pisca-pisca
   :name: blink_button
   :lines: 43-54

Enquanto o algoritmo se concentra no teste do botão de pressão,
é necessário assegurar a intermitência do LED.
Essa tarefa é realizada pela função ``blink_processing``
(:numref:`blink_processing`) que é continuamente invocada nas linhas 5 ou 10 da
:numref:`blink_button`.

.. literalinclude:: ../code/blink_button.s
   :language: c
   :linenos:
   :caption: Geração da intermitência do pisca-pisca
   :name: blink_processing
   :lines: 115-124

A variável ``led_state`` representa o estado instantâneo do LED -- aceso ou apagado.

Em cada invocação, a função ``blink_processing`` verifica a passagem
do tempo de intermitência (linha 2).
No fim de cada lapso de tempo, se a intermitência estiver ativada (linha 3),
a representação do estado do LED é invertida (linha 4), senão é colocada como apagado (linha 6).
No final, o estado do LED é atualizado (linha 7)
e é reiniciada uma nova temporização (linha 8).

Na função ``blink_init`` (:numref:`blink_init`) procede-se
à inicialização das variáveis de representação de estado (linhas 2 e 3),
ao início da primeira temporização (linha 4)
e à atualização do LED (linha 5).

.. literalinclude:: ../code/blink_button.s
   :language: c
   :linenos:
   :caption: Inicialização do estado do pisca-pisca
   :name: blink_init
   :lines: 90-95

**Código completo:** :download:`blink_button.s<../code/blink_button.s>`

**Teste em Logisim:**
   - Cicuito: :download:`sdp16_timer_counter.circ<../../example1/logisim/sdp16_timer_counter.circ>`

   - *Screenshot*: :download:`Screenshot_Logisim_counter<../../example1/logisim/Screenshot_Logisim_counter.png>`

   - Compilação do programa: ``p16as blink_button.s -f logisim -l 2``

**Exercícios:**

1. Alterar a programação,
de modo que o pisca-pisca desligue automaticamente ao fim de algum tempo,
num comportamento semelhante ao do exemplo da :numref:`Timers_exemplo2`.
