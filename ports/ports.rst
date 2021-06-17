Portos de entrada e saída
=========================

O P16 dispõe de um único espaço de endereçamento onde são mapeados os
portos de entrada e os portos de saída (periféricos) e a memória principal.
O acesso aos portos de entrada realiza-se utilizando a instrução **ldr**,
como a leitura de uma variável em memória.
O acesso aos portos de saída realiza-se utilizando a instrução **str**,
como a escrita numa variável em memória.
Para realizar o acesso a um porto é necessário determinar
o seu endereço no espaço de endereçamento.
Este endereço é definido ao nível do *hardware* e pode ser diferente de sistema para sistema.
No mesmo endereço podem existir um porto de entrada e um porto de saída,
porque a respetiva ativação depende do sinal **nRD**, no caso do porto de entrada,
ou do sinal **nWR**, no caso do porto de saída.

Tópicos tratados na :numref:`Portos_exemplo1`:
   - acesso a porto de 8 *bits* em endereço par.

Tópicos tratados na :numref:`portos_exemplo2`:
   - acesso a porto de 8 *bits* em endereço ímpar;
   - acesso individualizado a *bits* dos portos.

Tópicos tratados na :numref:`portos_exemplo3`:
   - definição de API de acesso aos portos: `port_input`; `port_output`;
   - deteção de transição num sinal de entrada.

Tópicos tratados na :numref:`portos_exemplo4`:
   - deteção de transição em mais que um sinal de entrada;
   - acesso a *bits* do mesmo porto de saída em contextos diferentes -- função `port_write`.

.. toctree::
   :maxdepth: 2

   example1/doc/in_out.rst
   example2/doc/led_button.rst
   example3/doc/led_click.rst
   example4/doc/7segment.rst
