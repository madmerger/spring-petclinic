{{/*
Metadata labels (excluding app — set explicitly per template)
*/}}
{{- define "petclinic.metaLabels" -}}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
release: {{ .Release.Name }}
{{- end }}

{{/*
App labels for the main petclinic deployment
*/}}
{{- define "petclinic.labels" -}}
app: {{ .Release.Name }}
{{ include "petclinic.metaLabels" . }}
{{- end }}

{{/*
Selector labels for the main petclinic deployment
*/}}
{{- define "petclinic.selectorLabels" -}}
app: {{ .Release.Name }}
{{- end }}

{{/*
App labels for the database deployment
*/}}
{{- define "petclinic.dbLabels" -}}
app: {{ .Release.Name }}-db
{{ include "petclinic.metaLabels" . }}
{{- end }}

{{/*
Selector labels for the database deployment
*/}}
{{- define "petclinic.dbSelectorLabels" -}}
app: {{ .Release.Name }}-db
{{- end }}
