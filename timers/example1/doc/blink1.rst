.. _Timers_exemplo11:

Temporização baseada no tempo de processamento
**********************************************

A temporização baseada na duração de processamento pode ser realizada
como mostra a implementação da função ``delay`` na :numref:`delay_soft`.
O valor do parâmetro ``time`` é sucessivamente decrementado até chegar a zero.
A duração da temporização depende do valor deste parâmetro
e do tempo de processamento das instruções executadas no ciclo.

.. code-block:: c
   :linenos:
   :caption: Função ``delay`` baseada em tempo de processamento
   :name: delay_soft

   void delay(uint16_t time) {
   	while (time-- > 0)
   		;
   }

A duração da temporização pode ser determinada pela análise
do código máquina resultante da tradução da função ``delay`` (:numref:`delay_soft_asm`),
conhecendo o tempo que cada instrução demora a executar.

.. code-block:: asm
   :linenos:
   :caption: Função ``delay`` baseada em tempo de processamento, em linguagem *assembly*
   :name: delay_soft_asm

   delay:
   	sub	r0, r0, 0
   	beq	delay_exit
   delay_while:
   	sub	r0, r0, 1
   	bzc	delay_while
   delay_exit:
   	mov	pc, lr

O tempo que cada instrução demora a executar depende da frequência do relógio
principal do processador e da micro-arquitetura, isto é, da implementação *hardware*.
Na implementação disponível do processador P16, as instruções ``ldr`` e ``str``
demoram seis periodos de relógio a executar e as restantes demoram três.

O número de ciclos de relógio gastos na execução desta função é
**3 + 3 + (3 + 3) * time + 3**.
A parcela **3 + 3** inicial é devida às instruções ``sub r0, r0, 0`` e ``beq delay_exit``
que executam apenas uma vez;
a parcela **(3 + 3) * time** é devida às instruções ``sub r0, r0, 1`` e ``bzc delay_while``
que executam ``time`` vezes;
a parcela **+ 3** final é devida à instrução ``mov pc, lr``.

Este método de realizar temporização,
com base no tempo de execução das instruções, não é generalizável.
Depende da frequência do relógio do processador
e do método *hardware* de implementação da micro-arquitetura.
Quando se programa em linguagem de alto nível, que é a situação mais comum,
depende também do código binário gerado pelo compilador.

**Código completo:** :download:`blink1.s<../code/blink1.s>`

**Logisim:**
   - Cicuito: :download:`sdp16_timer_soft.circ<../logisim/sdp16_timer_soft.circ>`
   - *Screenshot*: :download:`Screenshot_Logisim_soft<../logisim/Screenshot_Logisim_soft.png>`
   - Compilação:

   .. code-block:: console

      pas blink1.s -f logisim -l 2

**Exercício:**

1. Intercalar instruções no ciclo ``delay_while`` e verificar o efeito.
Por exemplo, se intercalar mais duas instruções,
deve, aproximadamente, duplicar a duração da temporização.

