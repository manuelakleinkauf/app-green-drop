# 🔐 Sistema de Controle de Acesso - GreenDrop

## Perfis de Usuário

### 👤 Doador (Padrão)
**Permissões:**
- ✅ Visualizar pontos de coleta no mapa
- ✅ Registrar doações
- ✅ Ver histórico de suas próprias doações
- ✅ Ver ranking de doadores
- ❌ Cadastrar/editar/desativar pontos de coleta

**Características:**
- Perfil padrão para novos usuários
- Foco em doar e acompanhar seu impacto ambiental

---

### 🙋 Voluntário
**Permissões:**
- ✅ Visualizar pontos de coleta no mapa
- ✅ Cadastrar novos pontos de coleta
- ✅ Editar pontos que ele criou
- ✅ Ativar/desativar apenas pontos que ele criou
- ✅ Ver pontos de outros voluntários (mas não pode editar)
- ❌ Registrar doações
- ❌ Editar/desativar pontos de outros voluntários

**Características:**
- Responsável por gerenciar a rede de pontos de coleta
- Cada voluntário é "dono" dos pontos que cadastra
- Não pode interferir nos pontos de outros

---

### 👑 Administrador
**Permissões:**
- ✅ **TODAS** as permissões de Doador e Voluntário
- ✅ Registrar doações
- ✅ Cadastrar/editar/desativar qualquer ponto de coleta
- ✅ Gerenciar pontos criados por qualquer pessoa
- ✅ Acesso completo ao sistema

**Características:**
- Controle total sobre o sistema
- Pode corrigir/atualizar qualquer informação
- Supervisionar todos os voluntários e doadores

---

## Implementação Técnica

### Arquivos Principais

1. **`lib/model/user_role.dart`**
   - Enum com os 3 perfis
   - Métodos de verificação de permissões

2. **`lib/model/user.dart`**
   - Campo `role` do tipo `UserRole`
   - Métodos helpers: `canRegisterDonation`, `canCreateCollectionPoint`, etc.

3. **`lib/viewmodel/current_user_provider.dart`**
   - Provider que mantém o usuário atual
   - Facilita verificação de permissões em qualquer tela

4. **`lib/repository/auth_repository.dart`**
   - Registra usuário com role escolhido
   - Salva role no Firestore

### Páginas com Controle de Acesso

#### MapPage
- Botão FAB (adicionar ponto) só aparece para Voluntários e Admins
- Doadores só visualizam o mapa

#### CollectionPointManagementPage
- Tela inteira bloqueada para Doadores
- Voluntários veem todos os pontos, mas só podem editar os seus
- Admins podem editar qualquer ponto

#### RegisterDonationPage
- Bloqueada para Voluntários
- Apenas Doadores e Admins podem registrar doações

#### RegisterPage
- Permite escolher o perfil ao criar conta
- 3 opções: Doador, Voluntário, Administrador

---

## Como Usar

### Para desenvolvedores

**Verificar permissão em uma tela:**
```dart
final userProvider = Provider.of<CurrentUserProvider>(context);

if (userProvider.canCreateCollectionPoint) {
  // Mostrar botão ou funcionalidade
}
```

**Verificar se pode editar um ponto específico:**
```dart
final canEdit = userProvider.canEditCollectionPoint(point.createdBy);
```

**Obter role do usuário atual:**
```dart
final userRole = userProvider.userRole; // UserRole.doador, .voluntario ou .admin
```

---

## Fluxo de Dados

1. **Registro:** Usuário escolhe role → Salvo no Firestore (`users` collection)
2. **Login:** CurrentUserProvider carrega dados do Firestore
3. **Uso:** Cada tela verifica permissões antes de mostrar funcionalidades
4. **CollectionPoint:** Armazena `createdBy` (uid do criador) para controle de edição

---

## Segurança

⚠️ **Importante:** Este controle é apenas na interface (client-side).

**Para produção, implemente:**
- Firebase Security Rules no Firestore
- Validações no backend (Cloud Functions)
- Auditoria de ações sensíveis

**Exemplo de Security Rules:**
```javascript
match /collection_points/{pointId} {
  allow create: if request.auth.token.role in ['VOLUNTARIO', 'ADMIN'];
  allow update, delete: if request.auth.token.role == 'ADMIN' 
                        || resource.data.createdBy == request.auth.uid;
  allow read: if request.auth != null;
}
```

---

## Próximas Melhorias Sugeridas

1. **Aprovação de Pontos**
   - Pontos de voluntários precisam aprovação de admin

2. **Dashboard Admin**
   - Estatísticas gerais
   - Gerenciamento de usuários
   - Logs de ações

3. **Notificações**
   - Voluntário recebe notificação quando há doação no seu ponto

4. **Badges/Conquistas**
   - Reconhecimento para voluntários ativos
   - Incentivos para doadores frequentes
