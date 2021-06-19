## 목표

어느날 다음과 같은 요청사항이 들어왔다는 가정하에 만들어본다.

### 요청사항

- Access Key Pair가 생성 후 N시간을 초과하는 IAM User를 찾아 Slack Webhook을 이용하여 임의의 Slack Channel로 전송합니다.
- Slack Webhook을 통해 전송되는 정보에는 아래 내용을 포함합니다.
  - 해당 IAM User의 User name
  - 해당 IAM User의 "AKIA" 로 시작하는 Access Key ID
  - 해당 Access Key의 생성 시간

### 실행 방법

1. 만들어 놓은 스크립트를 k8s(job)으로 실행한다.

- 사용중인 k8s는 v1.18
- aws_key 및 slack_webhook은 변수로 처리하여 재사용 가능.

2. aws 인증은 알아서 했다는 전재하에

```sh
docker run -v ~/.aws:/root/.aws raphael9292/search-user
or
docker run -e AWS_SECRET_ACCESS_KEY=xxx -v ~/.aws:/root/.aws raphael9292/search-user
```
