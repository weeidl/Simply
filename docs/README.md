# docs/ — документация и аудит проекта Simply

Все файлы в этой папке написаны в ходе полного code-review приложения
**Simply** (Flutter SMS-forward app) и затем частично синхронизированы с
локальными исправлениями. Читай в порядке нумерации, но для актуального
статуса задач всегда сверяйся с `06_FIX_PROGRESS.md`.

| Файл | О чём |
|------|-------|
| [01_PRODUCT_OVERVIEW.md](./01_PRODUCT_OVERVIEW.md) | Для чего продукт, что он делает, стек, архитектура, схема данных. |
| [02_SCREENS_OVERVIEW.md](./02_SCREENS_OVERVIEW.md) | Полная карта экранов: что на каждом, какая логика, какие недостатки UX. |
| [03_BUGS_AND_ISSUES.md](./03_BUGS_AND_ISSUES.md) | ~50 багов и проблем, разбитых по приоритету (🔴/🟠/🟡/🟢). Предложения новых фич. |
| [04_SECURITY_AUDIT.md](./04_SECURITY_AUDIT.md) | Аудит безопасности. 24 пункта, включая E2EE, Firestore Rules, Google Play policy. |
| [05_ARCHITECTURE_IMPROVEMENTS.md](./05_ARCHITECTURE_IMPROVEMENTS.md) | План рефакторинга на 8 спринтов, от гигиены до CI/CD. |
| [06_FIX_PROGRESS.md](./06_FIX_PROGRESS.md) | Live-трекер: что уже исправлено в итерациях. |
| [07_RELEASE_SIGNING.md](./07_RELEASE_SIGNING.md) | Pre-release чеклист, Android keystore, Firestore rules deploy, iOS signing, App Store / Play blockers. |
| [08_CLAUDE_DESIGN_PROMPT.md](./08_CLAUDE_DESIGN_PROMPT.md) | Короткий рабочий промт для Claude Design: сильная, но бережная модернизация UI без потери узнаваемости. |

## Как пользоваться

1. Начни с **01_PRODUCT_OVERVIEW** — чтобы освежить в голове продукт целиком.
2. Открой **02_SCREENS_OVERVIEW** когда правишь какой-либо экран —
   в нём описаны все его состояния и проблемы.
3. **03_BUGS_AND_ISSUES** используй как backlog с ID (`B-XXX`) и ссылками на
   файлы; фактический статус части пунктов уже изменился, поэтому проверяй его
   через **06_FIX_PROGRESS**.
4. **04_SECURITY_AUDIT** — обязательно закрыть 🔴 пункты до любого релиза.
5. **05_ARCHITECTURE_IMPROVEMENTS** — дорожная карта рефакторинга.
6. Если запускаешь визуальный редизайн через Claude — начни с
   **08_CLAUDE_DESIGN_PROMPT**.

## Правила обновления

- При закрытии issue помечай в `03_BUGS_AND_ISSUES.md` (например, вычёркивай
  пункт или добавляй статус `✅ fixed in #PR-123`).
- Новые проблемы, обнаруженные в дальнейшем — добавляй в
  `03_BUGS_AND_ISSUES.md` с уникальным `B-XXX`.
- Новые security-наблюдения — в `04_SECURITY_AUDIT.md` с `S-XXX`.

## Краткая сводка состояния проекта (на дату аудита)

- **Работает**: регистрация, вход, forgot password по e-mail, перехват SMS на
  Android, отображение списка чатов, детали чата, копирование OTP по тапу,
  удаление устройства, кнопка «+» на Devices.
- **Не работает / заглушка**: Google/Apple auth, Edit Profile, Language,
  Push Notification screen, Privacy Policy.
- **Критичные блокеры релиза**:
  1. Release-сборка подписана debug-ключом.
  2. Privacy Policy пустая → сторы reject-нут.
  3. SMS хранятся без шифрования → риск утечки OTP-кодов.
  4. Baseline `firestore.rules` уже добавлен в репозиторий, но его деплой и
     валидация в Firebase ещё не подтверждены.
  5. SMS/foreground-service permissions и Google Play policy для `READ_SMS` /
     `RECEIVE_SMS` всё ещё требуют отдельной доработки и декларации.

Перед публикацией в Google Play / App Store обязательно закрыть все 🔴 из
`04_SECURITY_AUDIT.md`.
