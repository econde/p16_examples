.. _Timers_exemplo1:

Pisca-pisca
***********

Neste exemplo mostra-se como realizar um pisca-pisca com um LED
ligado no porto de saída do SDP16 conforme a :numref:`sdp16_led`.

.. figure:: sdp16_led.png
   :name: sdp16_led
   :align: center

   Porto de saída do SDP16 com LED no *bit* 0

O programa da :numref:`pisca-pisca` executa indefinidamente em ciclos,
realizando em cada ciclo a seguinte sequência de ações: acender o LED
(linha 3); realizar uma temporização de meio período (linha 4);
apagar o LED (linha 5); repetir a temporização (linha 6).

A temporização consiste em impedir que o processamento prossiga
durante um certo periodo de tempo.
Assim, o LED vai permanecer acesso ou apagado durante a temporização que se segue.


.. code-block:: c
   :linenos:
   :caption: Programa para realizar o pisca-pisca
   :name: pisca-pisca

   #define	LED_MASK 	(1 << 0)
   #define	HALF_PERIOD	100

   void main() {
   	while (1) {
   		port_output(LED_MASK);
   		timer_delay(HALF_PERIOD);
   		port_output(0);
   		timer_delay(HALF_PERIOD);
   	}
   }

A temporização é realizada no interior da função ``timer_delay``.
São apresentadas duas soluções de implementação desta função:

.. toctree::
   :maxdepth: 2

   blink1.rst
   blink2.rst
