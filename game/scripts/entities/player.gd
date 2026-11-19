extends CharacterBody2D
## Player — classes estilo Rucoy (arma define classe), SKILLS Q/E + R/G (city2),
## flechas, critico, customizacao T/Y/U (tunica/cabelo/calca), LEVEL UP com efeito
## ANIMACOES: 4 direcoes REAIS (up/side/down) via procedural — idle/walk/attack/death

const EQUIPS = preload("res://scripts/autoload/equips.gd")
const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const SKILLS = preload("res://scripts/skills_db.gd")
