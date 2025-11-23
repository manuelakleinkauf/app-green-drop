# Cloud Functions - Instruções de Deploy

## Pré-requisitos

1. **Node.js 18 ou superior**
   - Baixe e instale: https://nodejs.org/

2. **Firebase CLI**
   - Instale executando no terminal:
   ```bash
   npm install -g firebase-tools
   ```

3. **Login no Firebase**
   ```bash
   firebase login
   ```

## Configuração Inicial

1. **Instalar dependências do Node.js**
   
   No diretório `functions/`, execute:
   ```bash
   cd functions
   npm install
   ```

## Deploy da Cloud Function

1. **Deploy para produção**
   ```bash
   firebase deploy --only functions
   ```

2. **Deploy de função específica**
   ```bash
   firebase deploy --only functions:geocodeAddress
   ```

## Testar Localmente (Opcional)

Para testar as functions localmente antes do deploy:

```bash
firebase emulators:start --only functions
```

Isso iniciará um emulador local na porta 5001.

## Configuração no Flutter

Depois do deploy, você não precisa fazer mais nada! A função já estará disponível automaticamente através do código no `map_viewmodel.dart`.

## Função Disponível

### `geocodeAddress`

**Entrada:**
```json
{
  "address": "Rua Henrique Juergensen, 1001, Centro, Três Coroas"
}
```

**Saída:**
```json
{
  "latitude": -29.5089,
  "longitude": -50.7794,
  "displayName": "Rua Henrique Juergensen, Centro, Três Coroas, RS, Brasil"
}
```

## Troubleshooting

### Erro de permissão
Se receber erro de permissão, execute:
```bash
firebase login --reauth
```

### Erro de região
Se houver problema com região, adicione no código da function:
```javascript
exports.geocodeAddress = functions
  .region('us-central1') // ou 'southamerica-east1'
  .https.onCall(...)
```

## Custos

O Firebase oferece um plano gratuito (Spark Plan) que inclui:
- 2 milhões de invocações/mês
- 400.000 GB-segundos de processamento
- 200.000 GB-segundos de CPU

Para este projeto, dificilmente você ultrapassará o limite gratuito.
