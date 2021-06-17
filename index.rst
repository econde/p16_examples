.. P16 - Processador didático documentation master file, created by
   sphinx-quickstart on Tue Jul  2 09:29:16 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Introdução
==========

Este documento apresenta um conjunto de exemplos de aplicação do P16
na interação com dispositivos periféricos.
Os exemplos são apresentados numa sequência que visa a introdução gradual de soluções.
Devem se analisados pela ordem com que estão apresentados,
quer pela ordem dos capítulos, quer dentro de cada capítulo.
Em regra, as soluções são explicadas na primeira vez em que são aplicadas.
Um exemplo mais adiantado que utilize uma solução já utilizada
num exemplo anterior, não terá a explicação dessa solução.

O *software* utilizado é primeiramente apresentado em linguagem C
para facilitar a descrição e a percepção algorítmica.
Em seguida é apresentado em linguagem *assembly*, na totalidade ou parcialmente,
acompanhado de explicação detalhada dos aspectos essenciais.

Com o objetivo de facilitar a replicação dos exemplos,
os esquemas eléctricos são apresentados com detalhe
para minimizar o recurso a outras fontes de informação.
Designadamente, as ligações são apresentadas em esquema unifilar,
com indicação das referências dos pinos de ligação.

No final dos exemplos existem:
   - Sugestões de exercícios, normalmente variações à solução apresentada;
   - *link* para o código do programa completo;
   - *link* para o circuito Logisim [#f1]_ onde o exemplo pode ser simulado.

.. sidebar:: *Feedbak*

   Alertas para erros, comentários e sugestões devem ser enviados para `ezequiel.conde[at]isel.pt`.

.. toctree::
   :maxdepth: 2
   :numbered:

   ports/ports.rst
   timers/timers.rst
   interrupts/interrupts.rst

.. rubric:: Footnotes

.. [#f1] Baseado na implementação do P16 em Logisim realizada pelo Prof. José Paraíso
   disponível `aqui <https://www.dropbox.com/s/cm1cpjtorz7ln45/P16_V1.6.circ?dl=0>`_.
