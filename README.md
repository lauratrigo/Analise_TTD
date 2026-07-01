# 🌎 Detecção de Distúrbios Ionosféricos (TTD) Associados a Terremotos

Este repositório contém o código desenvolvido em **MATLAB** para o processamento de dados GNSS e construção de **Time-Travel Diagrams (TTDs)** utilizados na identificação de perturbações ionosféricas associadas ao terremoto ocorrido na **Argentina em 22 de agosto de 2025**.

O processamento utiliza dados de **Slant Total Electron Content (STEC)** provenientes de receptores GNSS da rede RBMC e de estações da América do Sul, permitindo acompanhar a propagação temporal e espacial das perturbações na ionosfera.

---

# 🎯 Objetivo

O projeto tem como objetivo detectar assinaturas ionosféricas relacionadas ao terremoto através da análise da variação do **STEC**, estimando a velocidade de propagação das perturbações observadas na ionosfera.

---

# 🚀 Funcionalidades

### 📡 Processamento dos Dados GNSS

- Leitura automática de arquivos `.Cmn`;
- Extração das observações de:
  - PRN;
  - STEC;
  - VTEC;
  - Latitude;
  - Longitude;
  - Ângulo de elevação;
- Cálculo da distância radial entre cada estação e o epicentro.

---

### 📈 Tratamento do Sinal

- Seleção de um satélite específico (PRN);
- Filtragem por ângulo de elevação (>30°);
- Remoção da tendência utilizando ajuste exponencial (`exp2`);
- Aplicação de filtro passa-banda aproximado através de médias móveis;
- Isolamento das oscilações ionosféricas.

---

### 🌍 Construção do TTD (Time-Travel Diagram)

- Organização das estações por distância ao epicentro;
- Plotagem individual das séries temporais;
- Visualização da propagação das perturbações;
- Estimativa da velocidade aparente do TTD.

---

# ⚙️ Fluxo de Processamento

```text
Arquivos .Cmn
        │
        ▼
Leitura dos Dados
        │
        ▼
Seleção do PRN
        │
        ▼
Filtro de Elevação (>30°)
        │
        ▼
Remoção da Tendência
(Ajuste Exponencial)
        │
        ▼
Filtro por Médias Móveis
        │
        ▼
Extração do STEC Residual
        │
        ▼
Seleção Manual das Estações
        │
        ▼
Construção do Time-Travel Diagram
        │
        ▼
Estimativa da Velocidade de Propagação
```

---

# 📂 Estrutura do Projeto

```text
TTD-Earthquake-Argentina-2025
│
├── Dados
│   ├── *.Cmn
│   └── Distância radial.txt
│
├── Figuras
│   ├── TTD_PRN1.png
│   ├── TTD_PRN3.png
│   └── ...
│
├── Funções
│   ├── distancia_radial.m
│   └── ...
│
├── ttd.m
├── README.md
└── LICENSE
```

---

# 🔧 Critérios Utilizados

Durante o processamento foram adotados os seguintes critérios:

- Utilização de apenas um satélite GNSS por análise (PRN);
- Ângulo de elevação superior a **30°**;
- Intervalo temporal correspondente ao período do evento;
- Remoção da tendência de fundo do STEC;
- Filtragem das oscilações de baixa frequência;
- Seleção manual das estações que apresentaram assinaturas coerentes da perturbação.

---

# 📊 Variáveis Utilizadas

Os arquivos `.Cmn` fornecem:

| Variável | Descrição |
|----------|-----------|
| MJDate | Data Juliana Modificada |
| Time | Tempo (UT) |
| PRN | Satélite observado |
| Az | Azimute |
| Ele | Ângulo de elevação |
| Latitude | Latitude do Ponto Ionosférico |
| Longitude | Longitude do Ponto Ionosférico |
| STEC | Slant Total Electron Content |
| VTEC | Vertical Total Electron Content |
| S4 | Índice de cintilação |

---

# 📌 Por que utilizar o STEC?

O **Slant Total Electron Content (STEC)** representa a quantidade de elétrons ao longo do caminho percorrido pelo sinal GNSS entre o satélite e o receptor.

Após um terremoto de grande magnitude, ondas atmosféricas podem atingir a ionosfera, alterando a densidade eletrônica local. Essas alterações provocam variações no STEC, permitindo identificar a propagação das perturbações através dos Time-Travel Diagrams.

---

# 📐 Estimativa da Velocidade do TTD

A velocidade aparente da perturbação é estimada pela razão entre:

```text
Velocidade = ΔDistância / ΔTempo
```

onde:

- ΔDistância corresponde à diferença entre as distâncias radiais das estações ao epicentro;
- ΔTempo é obtido pela inclinação observada no Time-Travel Diagram.

---

# 🛠️ Tecnologias Utilizadas

- MATLAB
- GNSS
- Dados TEC (.Cmn)
- Time-Travel Diagram (TTD)
- Processamento Digital de Sinais

---

# 📚 Referências

- Afraimovich, E. L. et al. (2001). *Traveling Ionospheric Disturbances.*
- Heki, K. (2006). *Explosion energy of the 2004 Sumatra-Andaman earthquake inferred from ionospheric disturbances.*
- Liu, J. Y. et al. (2011). *Seismo-ionospheric perturbations.*

---

# 👩‍💻 Autora

**Laura Trigo**

Projeto desenvolvido no âmbito das pesquisas em monitoramento ionosférico utilizando dados GNSS para análise de perturbações associadas a terremotos.
