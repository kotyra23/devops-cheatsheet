import requests
import os

print("🤖 Помощник настройки Telegram Alertmanager")
print("1. Убедись, что ты создал бота в @BotFather и скопировал токен.")
print("2. Убедись, что ты написал этому боту слово 'Привет' в Telegram.\n")

token = input("Вставь токен бота сюда и нажми Enter: ").strip()

print("\n🔄 Ищу твой Chat ID в Telegram API...")
url = f"https://api.telegram.org/bot{token}/getUpdates"
response = requests.get(url, timeout=10).json()

if response.get("ok") and response.get("result"):
    # Берем последнее сообщение от пользователя
    chat_id = response["result"][-1]["message"]["chat"]["id"]
    print(f"✅ Успех! Твой Chat ID: {chat_id}")

    # Формируем конфиг для Alertmanager (обрати внимание на {{{{ для экранирования Jinja2)
    config_content = f"""global:
  resolve_timeout: 5m

route:
  receiver: 'telegram'
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h

receivers:
  - name: 'telegram'
    telegram_configs:
      - bot_token: '{token}'
        chat_id: {chat_id}
        send_resolved: true
        message: |
          ⚠️ *Alert:* {{{{ .GroupLabels.alertname }}}}
          🔴 *Status:* {{{{ .Status }}}}
          📝 *Description:* {{{{ .Annotations.description }}}}
          ⏰ *Time:* {{{{ .StartsAt.Format "2006-01-02 15:04:05" }}}}
"""
    os.makedirs("infra/docker", exist_ok=True)
    with open("infra/docker/alertmanager.yml", "w", encoding="utf-8") as f:
        f.write(config_content)

    print(
        "✅ Файл infra/docker/alertmanager.yml успешно создан и заполнен твоими данными!"
    )
else:
    print("❌ Ошибка: не удалось получить Chat ID.")
    print("Проверь, что:")
    print("1. Токен скопирован полностью и без лишних пробелов.")
    print("2. Ты действительно написал сообщение этому боту в Telegram.")
    print("Ответ API:", response)
