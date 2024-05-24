# Borrado Seguro

>Autor: Agustin Alvarez

>Fecha: 22/5/2024

>Versión: 1.0

>Lenguaje: Bash


## Descripción

Script que permite la identificación del disco magnético, SSD o NVMe y emplear el método de borrado mas adecuado.
Excluye del borrado los pendrives, solo se centra en unidades de disco local
Para su uso requiere que se tenga instalado las herramientas nvme-cli, hdparm, shred (incluido en el paquete coreutils), el script verifica que se encuentren presetes las herramientas
Al finalizar muestra un mensaje y reinicia la computadora
Se creo con la finalidad de brindar un herramienta sencilla y opensource a soporte técnico para el borrado seguro de discos.
Para el borrado intenta usar la instrucción de secure erase si lo soporta el disco, en caso contrario utiliza Shred para borrar el disco realizando algunas pasadas con datos pseudo aleatorios.


## Changelog
21/5/2024	Release incial