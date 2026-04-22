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
| [07_EXECUTION_PLAN.md](./07_EXECUTION_PLAN.md) | Практический план ближайшей серии правок: streams, stable deviceId, lifecycle fixes. |
| [08_SECURITY_DEVICE_PLAN.md](./08_SECURITY_DEVICE_PLAN.md) | План security/device hardening: encryption, rules, stable device identity. |

## Как пользоваться

1. Начни с **01_PRODUCT_OVERVIEW** — чтобы освежить в голове продукт целиком.
2. Открой **02_SCREENS_OVERVIEW** когда правишь какой-либо экран —
   в нём описаны все его состояния и проблемы.
3. **03_BUGS_AND_ISSUES** используй как backlog с ID (`B-XXX`) и ссылками на
   файлы; фактический статус части пунктов уже изменился, поэтому проверяй его
   через **06_FIX_PROGRESS**.
4. **04_SECURITY_AUDIT** — обязательно закрыть 🔴 пункты до любого релиза.
5. **05_ARCHITECTURE_IMPROVEMENTS** — дорожная карта рефакторинга.

## Правила обновления

- При закрытии issue помечай в `03_BUGS_AND_ISSUES.md` (например, вычёркивай
  пункт или добавляй статус `✅ fixed in #PR-123`).
- Новые проблемы, обнаруженные в дальнейшем — добавляй в
  `03_BUGS_AND_ISSUES.md` с уникальным `B-XXX`.
- Новые security-наблюдения — в `04_SECURITY_AUDIT.md` с `S-XXX`.

## Текущий статус проекта

**Режим использования:** личное приложение автора, публикация в Google Play /
App Store пока не планируется. Соответственно release-блокеры (подпись,
политика конфиденциальности, SMS-декларация и т.п.) не являются stop-ship'ами —
только техническая корректность.

Последняя синхронизация с кодом: **2026-04-22**.

### Работает
- Регистрация, вход, forgot password по e-mail.
- Перехват SMS на Android (включая фон — фикс 2026-04-22, см.
  `06_FIX_PROGRESS.md` Итерация 2).
- Список чатов, детали чата, копирование OTP по тапу.
- Удаление устройства, кнопка «+» на Devices.

### Заглушки / не реализовано
- Google/Apple auth, Edit Profile, Language, Push Notification screen,
  Privacy Policy.

### Что осталось, если когда-то захочется в стор
- Release-сборка подписана debug-ключом (B-005).
- Privacy Policy пустая (B-042 / S-004).
- Firestore rules уже ужесточены в репозитории, но их деплой в реальный
  Firebase-проект нужно подтвердить отдельно (S-002).
- Шифрование SMS включается через password-wrapped master key после следующего
  логина пользователя; rollout/миграцию стоит проверить на живом проекте (S-001).
- SMS / foreground-service policy для Google Play (S-005, S-006).
