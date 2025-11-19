# Guia Rápido: Deploy da Cloud Function

## 📋 Checklist de Deploy

### 1️⃣ Instalar Firebase CLI (se ainda não tiver)
```powershell
npm install -g firebase-tools
```

### 2️⃣ Fazer login no Firebase
```powershell
firebase login
```

### 3️⃣ Instalar dependências da função
```powershell
cd functions
npm install
cd ..
```

### 4️⃣ Fazer deploy da função
```powershell
firebase deploy --only functions
```

### 5️⃣ Instalar o pacote cloud_functions no Flutter
```powershell
flutter pub get
```

### 6️⃣ Testar!
Execute seu app e tente cadastrar um novo ponto de coleta. Agora não terá mais erro de CORS! 🎉

---

## ⚠️ Notas Importantes

1. O deploy pode levar alguns minutos na primeira vez
2. Você precisa estar no **plano Blaze** (paga conforme uso) do Firebase para usar Cloud Functions
   - Mas não se preocupe: há um limite generoso gratuito que você dificilmente ultrapassará
3. Após o primeiro deploy, você pode ver sua função no console do Firebase:
   - https://console.firebase.google.com/project/green-drop-e7b59/functions

## 🔍 Como verificar se funcionou

1. Após o deploy, você verá uma mensagem como:
   ```
   ✔  functions[geocodeAddress(us-central1)] Successful create operation.
   ```

2. No console do Firebase, vá em "Functions" e você verá sua função listada

3. Teste adicionando um ponto de coleta no seu app!
