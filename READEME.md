# N8N Video Generator - Google Veo 3.0

Sistema automatizado de geração de vídeos usando **Google Veo 3.0**, **Gemini** e **n8n** com agentes AI autônomos.

## ✨ Funcionalidades

- Geração Inteligente de Roteiros via Gemini
- Criação de Vídeos com Google Veo 3.0
- Processamento Assíncrono com Agentes AI
- Continuidade Visual entre cenas
- Gestão de Estado com Baserow
- Concatenação automática com FFmpeg

## 🏗️ Arquitetura

┌─────────────────┐
│ Chat Interface  │
└────────┬────────┘
         │
         ▼
┌──────────────────────────────────┐
│ veo3 (Main Flow)                 │
│ ┌──────────────┐ ┌─────────────┐ │
│ │ Extrai Params│→│ Gera Roteiro│ │
│ └──────────────┘ └──────┬──────┘ │
│                         ▼        │
│ ┌──────────────────────────────┐ │
│ │ Video Creator Agent (AI)     │ │
│ │ - Busca cenas pending        │ │
│ │ - Inicia geração de vídeos   │ │
│ └──────────┬───────────────────┘ │
│            ▼                     │
│ ┌──────────────────────────────┐ │
│ │ Video Processor Agent (AI)   │ │
│ │ - Monitora processamento     │ │
│ │ - Baixa vídeos prontos       │ │
│ │ - Extrai frames              │ │
│ └──────────┬───────────────────┘ │
│            ▼                     │
│ ┌──────────────────────────────┐ │
│ │ Concatena Vídeos (FFmpeg)    │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
        │
        ▼
Video Final.mp4

### Workflows:

1. **veo3** - Workflow principal com agentes AI
2. **create-video** - Inicializa criação via Veo API
3. **video-monitor** - Monitora e baixa vídeos
4. **extract-frame** - Extrai frames para continuidade
5. **config-server** - Servidor de configurações

## 📋 Pré-requisitos

### APIs:

- [Google Gemini API](https://ai.google.dev/) (gratuito)
- [Google Veo 3.0](https://labs.google/veo/) (preview - lista de espera)
- [Baserow](https://baserow.io/) (gratuito)

### Software:

- Docker & Docker Compose
- 4GB+ RAM
- 10GB+ espaço em disco

## 🚀 Instalação

### 1. Clone o repositório

````bash
git clone https://github.com/seu-usuario/n8n-video-generator.git
cd n8n-video-generator
2. Execute o setup
bashchmod +x setup.sh
./setup.sh
O script irá:

Verificar dependências
Criar .env e keys.env
Baixar imagens Docker
Iniciar n8n

3. Configure .env
Edite .env com suas chaves:
bashGOOGLE_GEMINI_API_KEY=sua_key_aqui
BASEROW_API_KEY=sua_key_aqui
4. Configure Baserow
Siga o guia detalhado: docs/BASEROW_SETUP.md
Resumo:

Crie tabela video_scenes em Baserow
Adicione os 10 campos necessários
Gere API token
Execute: ./update-baserow-ids.sh

5. Acesse n8n
Abra: http://localhost:5678

Crie conta de administrador
Configure credenciais:

Google Gemini API
Baserow API



6. Importe workflows
Workflows > Import > Selecione todos de /workflows
Ordem recomendada:

config-server.json
create-video.json
extract-frame.json
video-monitor.json
veo3.json

7. Ative workflows
Ative todos os workflows (toggle verde)
🎯 Como Usar
Via Chat:

Abra workflow veo3
Clique em Chat
Digite:

Crie um vídeo motivacional sobre superação com 3 cenas,
estilo cinematográfico, iluminação dramática

Aguarde ~3-5min por cena
Receba o vídeo final

Via API:
bashcurl -X POST http://localhost:5678/webhook/veo3 \
  -H "Content-Type: application/json" \
  -d '{
    "chatInput": "vídeo sobre natureza com 5 cenas"
  }'
🔧 Configurações
Número de cenas
3 cenas: Melhor qualidade (prompts até 320 chars)
5-6 cenas: Qualidade média (prompts até 200 chars)
8+ cenas: Prompts curtos (até 150 chars)
Qualidade do vídeo
No node "Execute Command1" do workflow principal:
bash# Alta qualidade (arquivo maior)
-crf 18

# Qualidade padrão
-crf 23

# Mais compressão (arquivo menor)
-crf 28
📊 Monitoramento
Logs:
bashdocker-compose logs -f n8n
Status no Baserow:
Acesse sua tabela para ver:

Progresso de cada cena
Status (pending/processing/done/error)
Mensagens de erro

Vídeos:
bashdocker exec n8n-video-generator ls -la /tmp/videos/
🐛 Troubleshooting
Consulte docs/TROUBLESHOOTING.md
Problemas Comuns:
Veo API não responde:

Você está na lista de espera
Inscreva-se aqui

Baserow unauthorized:

Verifique token no .env
Atualize credencial no n8n

FFmpeg não encontrado:
bashdocker-compose down
docker-compose up -d --build
📚 Documentação

Baserow Setup
Arquitetura
Troubleshooting

🔒 Segurança
Para Produção:

Mude senhas:

bashN8N_ENCRYPTION_KEY=sua-chave-aleatoria-segura

Use HTTPS com reverse proxy (Nginx/Traefik)
Restrinja portas no firewall

🤝 Contribuindo
Pull requests são bem-vindos!

Fork o projeto
Crie sua feature (git checkout -b feature/MinhaFeature)
Commit (git commit -m 'Add: minha feature')
Push (git push origin feature/MinhaFeature)
Abra um Pull Request

📝 Licença
MIT License
⚠️ Disclaimer
Google Veo 3.0 está em preview. O sistema funcionará parcialmente até você obter acesso.

Dúvidas? Abra uma issue

---

## 📄 `docs/BASEROW_SETUP.md`
```markdown
# Guia Completo: Configuração Baserow

## Estrutura da Tabela

### Campos Necessários

| Campo | Tipo | Config | Obrigatório |
|-------|------|--------|-------------|
| id | Number | Auto-increment | Sim |
| session_id | Text | - | Sim |
| index | Text | - | Sim |
| prompt | Long Text | - | Sim |
| status | Single Select | 4 opções | Sim |
| create_url_video | Text | - | Não |
| frame_base64 | Long Text | - | Não |
| error | Long Text | - | Não |
| continuity_elements | Long Text | - | Não |
| created_at | Date | Com hora | Não |

### Status Options (EXATO):
pending (amarelo)
processing (azul)
done (verde)
error (vermelho)

## Passo a Passo

### 1. Criar Conta

https://baserow.io → Sign Up

### 2. Criar Database

New Workspace → New Database → Nome: "Video Generator"

### 3. Criar Tabela

New Table → Nome: "video_scenes"

### 4. Adicionar Campos

Clique em "+" para cada campo:
id → Number → Auto-increment ativado
session_id → Text
index → Text
prompt → Long Text
status → Single Select → Adicione as 4 opções
create_url_video → Text
frame_base64 → Long Text
error → Long Text
continuity_elements → Long Text
created_at → Date → Include time ativado

### 5. Obter IDs

**Database ID:**
URL: https://baserow.io/database/[DB_ID]/table/[TABLE_ID]
^^^^^^
Copie este número

**Table ID:**
URL: https://baserow.io/database/[DB_ID]/table/[TABLE_ID]
^^^^^^^^
Copie este número

**Field IDs:**

Para cada campo:
1. Clique no nome do campo
2. Settings (engrenagem)
3. Copie "Field ID"

Anote:
session_id = _______
index = _______
prompt = _______
status = _______
frame_base64 = _______
create_url_video = _______

### 6. Gerar Token

Settings → API Tokens → Create Token → Copy

Exemplo: `uWZOGSVeUvifM6eMdmbmHdYeZRtIuFSp`

### 7. Atualizar Configurações

**No `.env`:**
```bash
BASEROW_API_KEY=seu_token_aqui
Nos workflows:
bash./update-baserow-ids.sh
Siga o assistente e informe todos os IDs.
Teste
Linha de Teste:
Crie manualmente:
session_id: test-123
index: scene_1
prompt: Teste de integração
status: pending
Execute workflow:
bashcurl -X POST http://localhost:5678/webhook/create-video \
  -H "Content-Type: application/json" \
  -d '{"body": {"rowId": [ID_DA_LINHA]}}'
Verifique se status mudou para processing.
Monitoramento
Filtros Úteis:

Status = pending → Aguardando
Status = processing → Em andamento
Status = done → Concluídos
Status = error → Com problema

Views Recomendadas:
View 1: Em Progresso
Filter: status = processing OR status = pending
Sort: created_at DESC
View 2: Concluídos Hoje
Filter: status = done AND created_at = today
Sort: created_at DESC
View 3: Erros
Filter: status = error
Sort: created_at DESC
Exemplo Real
json{
  "id": 199,
  "session_id": "video-superacao-1759003088098",
  "index": "scene_1",
  "prompt": "Pessoa sentada em ambiente escuro, cabeça baixa...",
  "status": "done",
  "create_url_video": "models/veo-3.0-generate-preview/operations/wu9c7ow...",
  "frame_base64": null,
  "error": "",
  "created_at": "2024-01-15T10:30:00Z"
}
Problemas Comuns
"Table not found"

Verifique Table ID na URL
Atualize em todos workflows
Reimporte workflows

"Unauthorized"

Gere novo token
Atualize .env
Reinicie n8n

"Field not found"

Verifique Field IDs
Execute update-baserow-ids.sh novamente


Próximo: Configure credenciais no n8n

---

## 📄 `docs/ARCHITECTURE.md`
```markdown
# Arquitetura do Sistema

## Visão Geral
┌─────────────┐
│   Cliente   │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────┐
│         n8n Container           │
│                                 │
│  ┌───────────────────────────┐  │
│  │   Workflow Principal      │  │
│  │   (veo3)                  │  │
│  └─────────┬─────────────────┘  │
│            │                    │
│  ┌─────────▼─────────────────┐  │
│  │  Video Creator Agent      │  │
│  │  (Busca/Inicia Vídeos)    │  │
│  └─────────┬─────────────────┘  │
│            │                    │
│  ┌─────────▼─────────────────┐  │
│  │  Video Processor Agent    │  │
│  │  (Monitora/Processa)      │  │
│  └─────────┬─────────────────┘  │
│            │                    │
│  ┌─────────▼─────────────────┐  │
│  │  FFmpeg Concatenation     │  │
│  │  (União Final)            │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
    │               │
    │               └──────────┐
    ▼                          ▼
┌─────────────────┐    ┌──────────────┐
│  Google Veo API │    │   Baserow    │
│  Google Gemini  │    │   (Estado)   │
└─────────────────┘    └──────────────┘

## Componentes

### 1. Workflows

#### veo3 (Principal)
- Recebe prompt do usuário
- Extrai parâmetros (estilo, cenas, etc)
- Gera roteiro completo
- Cria primeira imagem
- Inicializa estado no Baserow
- Coordena agentes AI
- Concatena vídeos finais

#### create-video
- Valida cena pending
- Verifica frame_base64
- Envia requisição para Veo API
- Atualiza status para processing

#### video-monitor
- Polling da operação Veo
- Espera 20s entre checks
- Baixa vídeo quando pronto
- Chama extract-frame

#### extract-frame
- Extrai último frame com FFmpeg
- Converte para base64
- Atualiza próxima cena
- Marca atual como done

#### config-server
- Lê keys.env
- Serve configurações
- Centraliza credentials

### 2. Agentes AI

#### Video Creator Agent
Responsabilidades:

Buscar próxima cena pending
Verificar cenas em processing
Chamar create-video
Passar controle ao Processor


#### Video Processor Agent
Responsabilidades:

Monitorar vídeos em processamento
Chamar video-monitor
Verificar conclusão de todas cenas
Decidir quando finalizar


### 3. Fluxo de Dados

User Input → Gemini (Extrai Params)
Params → Gemini (Gera Roteiro JSON)
Primeira Cena → Imagen (Gera Imagem)
Roteiro → Initialize State → Baserow (Cria Linhas)

Loop para cada cena:
5. Creator Agent → Busca Pending
6. Creator Agent → create-video
7. Veo API → Inicia Geração
8. Baserow → status = processing
9. Processor Agent → video-monitor
10. video-monitor → Polling Veo
11. Veo → Retorna Vídeo
12. video-monitor → extract-frame
13. extract-frame → FFmpeg (Extrai Frame)
14. extract-frame → Baserow (Atualiza Próxima + status=done)
15. Volta para 5 se houver pending
Finalização:
16. Processor Agent → Verifica all done
17. FFmpeg → Concatena Todos
18. Retorna vídeo final

### 4. Estado no Baserow
Ciclo de Vida de uma Cena:
pending
↓ (create-video)
processing
↓ (video-monitor)
video_ready
↓ (extract-frame)
done
Ou em caso de erro:
↓
error

### 5. Armazenamento
/tmp/videos/
└── {session-id}/
├── scene_0.mp4
├── scene_1.mp4
├── scene_2.mp4
└── final_video.mp4

## Tecnologias

- **n8n**: Orquestração
- **Gemini**: Roteiro + Parâmetros
- **Imagen**: Primeira imagem
- **Veo 3.0**: Geração de vídeos
- **Baserow**: Banco de dados
- **FFmpeg**: Processamento de vídeo
- **Docker**: Containerização

## Escalabilidade

### Limitações Atuais:
- Processamento sequencial
- Single container
- Rate limits das APIs

### Melhorias Futuras:
- Processamento paralelo de cenas
- Queue system (Redis)
- Múltiplas instâncias n8n
- CDN para vídeos finais

## Segurança

- API keys em environment variables
- Sem senhas hardcoded
- Tokens rotacionáveis
- Logs sanitizados

---

**Atualizado:** 2024-01-15

📄 docs/TROUBLESHOOTING.md
markdown# Troubleshooting Guide

## Problemas Comuns

### 1. Docker não inicia

**Erro:** `Cannot connect to Docker daemon`

**Solução:**
```bash
# Verifique se Docker está rodando
sudo systemctl start docker

# macOS/Windows
# Inicie Docker Desktop
2. n8n não responde
Erro: Cannot reach http://localhost:5678
Verificar:
bash# Status do container
docker-compose ps

# Logs
docker-compose logs n8n

# Reiniciar
docker-compose restart n8n
3. Baserow: Unauthorized
Erro: 401 Unauthorized nas chamadas API
Solução:

Gere novo token no Baserow
Atualize .env:

bash   BASEROW_API_KEY=novo_token_aqui

Execute update-baserow-ids.sh
Reinicie:

bash   docker-compose restart n8n
4. Baserow: Table not found
Erro: Table with id 680992 not found
Solução:

Verifique seu Table ID na URL do Baserow
Execute:

bash   ./update-baserow-ids.sh

Reimporte workflows no n8n

5. Gemini API Error
Erro: API key not valid
Solução:

Verifique chave em https://ai.google.dev/
Atualize .env:

bash   GOOGLE_GEMINI_API_KEY=sua_chave_correta

No n8n: Settings > Credentials > Atualize credencial
Reinicie:

bash   docker-compose restart n8n
6. Veo API não responde
Causa: Lista de espera
Status Atual:

Veo 3.0 está em preview
Precisa aprovação do Google

Ações:

Inscreva-se na lista
Enquanto isso:

Roteiros são criados normalmente
Dados ficam no Baserow
Quando tiver acesso, apenas ative workflows



7. FFmpeg: Command not found
Erro: ffmpeg: not found
Solução:
bash# Reconstruir container
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Verificar instalação
docker exec n8n-video-generator which ffmpeg
# Deve retornar: /usr/bin/ffmpeg
8. Vídeos não concatenam
Sintomas:

Todas cenas done
Mas vídeo final não é gerado

Verificar:
bash# Listar vídeos
docker exec n8n-video-generator ls -la /tmp/videos/{seu-session-id}/

# Deve mostrar scene_0.mp4, scene_1.mp4, etc
Solução:

Verifique se TODAS cenas têm status "done"
Verifique logs do FFmpeg:

bash   docker-compose logs n8n | grep ffmpeg

Teste FFmpeg manualmente:

bash   docker exec -it n8n-video-generator sh
   cd /tmp/videos/{session-id}/
   ls -la *.mp4
9. Workflow trava no Processor Agent
Sintomas:

Agent fica em loop
Não finaliza nunca

Causa: hasNextScene sempre true
Solução:

Verifique Baserow: todas cenas estão "done"?
Se sim, reinicie execution:

n8n > Executions > Pare a execution
Execute novamente



10. Credenciais não funcionam
Erro: Credentials not found
Solução:

n8n > Settings > Credentials
Crie credenciais:

Google Gemini:
Name: Google Gemini(PaLM) Api account
Type: Google PaLM
API Key: sua_key
Baserow:
Name: Baserow account
Type: Baserow API
Token: seu_token

Nos workflows, associe credenciais aos nodes

11. Memory/Performance
Sintomas:

n8n lento
Timeouts frequentes

Solução:

Aumente recursos Docker:

Settings > Resources > 4GB RAM
2 CPUs mínimo


Reduza número de cenas:

   "Crie vídeo com 3 cenas" (ao invés de 10)

Ajuste timeouts nos HTTP nodes:

json   "options": {
     "timeout": 60000
   }
12. Logs para Debug
bash# Logs em tempo real
docker-compose logs -f n8n

# Últimas 100 linhas
docker-compose logs --tail=100 n8n

# Filtrar por erro
docker-compose logs n8n | grep -i error

# Salvar logs
docker-compose logs n8n > debug.log
13. Resetar Tudo
Quando nada funciona:
bash# Para e remove containers
docker-compose down

# Remove volumes (PERDA DE DADOS!)
docker-compose down -v

# Limpa tudo
docker system prune -a --volumes

# Recomeça
./setup.sh
14. Problemas com Ports
Erro: Port 5678 already in use
Solução:
bash# Encontrar processo
lsof -i :5678

# Matar processo
kill -9 [PID]

# Ou mudar porta no .env
N8N_PORT=5679
Logs Úteis
Baserow API Call
bashcurl -X GET \
  "https://api.baserow.io/api/database/rows/table/[TABLE_ID]/?user_field_names=true" \
  -H "Authorization: Token [SEU_TOKEN]"
Testar Gemini
bashcurl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=[SUA_KEY]" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'
Suporte
Recursos:

n8n Community
Baserow Docs
Gemini API Docs

Reportar Bug:

Abra issue no GitHub
Inclua:

Mensagem de erro completa
Logs relevantes
Versão do Docker/n8n
Passos para reproduzir




Atualizado: 2024-01-15

---

## Como Usar Estes Arquivos:
```bash
# 1. Criar estrutura
mkdir -p n8n-video-generator/{workflows,docs}
cd n8n-video-generator

# 2. Copiar cada arquivo acima para seu respectivo local

# 3. Tornar scripts executáveis
chmod +x setup.sh update-baserow-ids.sh

# 4. Executar setup
./setup.sh

# 5. Seguir instruções do README.md
Todos os arquivos estão prontos para uso, sem PostgreSQL, focado apenas em n8n +
````
