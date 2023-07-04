{{/*
Return the ClickHouse image
*/}}
{{- define "clickhouse.image" -}}
"{{ .Values.image.repository }}:{{ .Values.image.tag }}"
{{- end -}}

{{/*
Return the ClickHouse backup image
*/}}
{{- define "backup.clickhouse.image" -}}
"{{ .Values.backup.image.repository }}:{{ .Values.backup.image.tag }}"
{{- end -}}

{{/*
Return the ClickHouse client image
*/}}
{{- define "client.clickhouse.image" -}}
"{{ .Values.client.image.repository }}:{{ .Values.client.image.tag }}"
{{- end -}}

{{/*
Return ClickHouse password config value for clickhouse_instance
*/}}
{{- define "clickhouse.passwordValue" -}}
{{- if .Values.existingSecret }}
      {{ .Values.user }}/k8s_secret_password: {{ .Release.Namespace }}/{{ .Values.existingSecret }}/{{ required "The existingSecretPasswordKey needs to be set when using an existingSecret" .Values.existingSecretPasswordKey }}
{{- else }}
      {{ .Values.user }}/k8s_secret_password: {{ .Release.Namespace }}/{{ template "clickhouse.fullname" . }}-{{ .Values.user }}-password/password
{{- end }}
{{- end }}

{{/*
Return ClickHouse backup password config value for clickhouse_instance
*/}}
{{- define "clickhouse.backupPasswordValue" -}}
{{- if .Values.backup.existingSecret }}
      {{ .Values.backup.backup_user }}/k8s_secret_password: {{ .Release.Namespace }}/{{ .Values.backup.existingSecret }}/{{ required "The backup.existingSecretPasswordKey needs to be set when using backup.existingSecret" .Values.backup.existingSecretPasswordKey }}
{{- else -}}
      {{ .Values.backup.backup_user }}/k8s_secret_password: {{ .Release.Namespace }}/{{ template "clickhouse.fullname" . }}-{{ .Values.backup.backup_user }}-password/password
{{- end}}
{{- end}}

{{/*
Return the services of the first replica of each ClickHouse shard as a csv.
*/}}
{{- define "clickhouse.shardServices" -}}
{{- $result := list -}}
{{- $name := include "clickhouse.fullname" . -}}
{{- range $i := until (int .Values.layout.shardsCount) -}}
{{- $serviceName := printf "service-%s-%s-0" $name (toString $i) -}}
{{ $result = append $result $serviceName }}
{{- end -}}
{{ join "," $result }}
{{- end }}
