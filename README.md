# Groq AI Dashboard 🚀

## Visão Geral

Bem-vindo ao **Groq AI Dashboard**, uma aplicação interativa construída com `shiny` que utiliza a poderosa API da Groq para gerar respostas inteligentes em tempo real! Este projeto foi desenvolvido para demonstrar como a integração entre R, Python e a tecnologia de ponta da Groq pode criar uma experiência de usuário fluida e interativa, permitindo consultas dinâmicas a um modelo de linguagem avançado.

## Funcionalidades Principais ✨

-   **Integração com a API da Groq**: Através da combinação do R e Python utilizando `reticulate`, você pode aproveitar a inteligência da API Groq diretamente na interface do `shiny`.
-   **Interatividade Completa**: A aplicação permite que os usuários enviem perguntas diretamente pelo painel e obtenham respostas contextuais e detalhadas em segundos.
-   **Interface Simples e Intuitiva**: Um design minimalista com `shinydashboard` garante uma experiência de usuário agradável, focada na funcionalidade.
-   **Segurança Incorporada**: Utilize variáveis de ambiente para manter suas chaves de API seguras, garantindo que informações sensíveis não sejam expostas no código ou em repositórios públicos.

## Como Funciona? 🤖

1.  **Entrada do Usuário**: Os usuários podem inserir qualquer pergunta no painel de texto da dashboard.
2.  **Processamento pela API Groq**: A pergunta é enviada para a API da Groq através de uma integração Python-R, onde o modelo de linguagem processa e gera uma resposta.
3.  **Resposta Instantânea**: A resposta é exibida diretamente no painel, proporcionando insights rápidos e precisos.

## Como Configurar e Executar 🛠️

### Pré-requisitos

-   **R e RStudio**: Certifique-se de ter o R e o RStudio instalados.
-   **Python**: Uma instalação de Python com os pacotes `numpy`, `pandas`, e `groq`.
-   **Pacotes R**: Instale os pacotes R necessários: \`\`\`r install.packages(c("shiny", "shinydashboard", "reticulate"))
