{{/*
Common labels
*/}}
{{- define "petclinic.labels" -}}
app: {{ .Release.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
release: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "petclinic.selectorLabels" -}}
app: {{ .Release.Name }}
{{- end }}
