{{/* vim: set filetype=mustache: */}}


{{/*
Return the proper flink image name
*/}}
{{- define "flink.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Create the name of the jobmanager deployment
*/}}
{{- define "flink.jobmanager.fullname" -}}
    {{ printf "%s-jobmanager" (include "common.names.fullname" .) }}
{{- end -}}

{{/*
Create the name of the service account to use for the taskmanager
*/}}
{{- define "flink.taskmanager.serviceAccountName" -}}
{{- if .Values.taskmanager.serviceAccount.create -}}
    {{ default (include "flink.taskmanager.fullname" .) .Values.taskmanager.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.taskmanager.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the agent
*/}}
{{- define "flink.agent.serviceAccountName" -}}
{{- if .Values.agent.serviceAccount.create -}}
    {{ default (include "flink.agent.fullname" .) .Values.agent.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.agent.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the jobmanager
*/}}
{{- define "flink.jobmanager.serviceAccountName" -}}
{{- if .Values.jobmanager.serviceAccount.create -}}
    {{ default (include "flink.jobmanager.fullname" .) .Values.jobmanager.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.jobmanager.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the taskmanager deployment
*/}}
{{- define "flink.taskmanager.fullname" -}}
    {{ printf "%s-taskmanager" (include "common.names.fullname" .) }}
{{- end -}}

{{/*
Create the name of the taskmanager deployment. This name includes 2 hyphens due to
an issue about env vars collision with the chart name when the release name is set to just 'flink'
ref. https://github.com/flinktracing/flink-operator/issues/1158
*/}}
{{- define "flink.agent.fullname" -}}
    {{ printf "%s--agent" (include "common.names.fullname" .) }}
{{- end -}}

{{/*
Create the cassandra secret name
*/}}
{{- define "flink.cassandra.secretName" -}}
    {{- if not .Values.cassandra.enabled -}}
        {{- .Values.externalDatabase.existingSecret -}}
    {{- else -}}
        {{- printf "%s-cassandra" (include "common.names.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{/*
Create the cassandra secret key
*/}}
{{- define "flink.cassandra.secretKey" -}}
    {{- if not .Values.cassandra.enabled -}}
        {{- .Values.externalDatabase.existingSecretPasswordKey -}}
    {{- else -}}
        cassandra-password
    {{- end -}}
{{- end -}}

{{/*
Create the cassandra user
*/}}
{{- define "flink.cassandra.user" -}}
    {{- if not .Values.cassandra.enabled -}}
        {{- .Values.externalDatabase.dbUser.user | quote -}}
    {{- else -}}
        {{- .Values.cassandra.dbUser.user | quote -}}
    {{- end -}}
{{- end -}}

{{/*
Create the cassandra host
*/}}
{{- define "flink.cassandra.host" -}}
    {{- if not .Values.cassandra.enabled -}}
        {{- .Values.externalDatabase.host | quote -}}
    {{- else -}}
        {{- include "common.names.dependency.fullname" (dict "chartName" "cassandra" "chartValues" .Values.cassandra "context" $) -}}
    {{- end }}
{{- end }}

{{/*
Create the cassandra port
*/}}
{{- define "flink.cassandra.port" -}}
    {{- if not .Values.cassandra.enabled -}}
        {{- .Values.externalDatabase.port | quote -}}
    {{- else }}
        {{- .Values.cassandra.service.ports.cql | quote -}}
    {{- end -}}
{{- end -}}

{{/*
Create the cassandra datacenter
*/}}
{{- define "flink.cassandra.datacenter" -}}
    {{- if not .Values.cassandra.enabled -}}
        {{- .Values.externalDatabase.cluster.datacenter | quote -}}
    {{- else }}
        {{- .Values.cassandra.cluster.datacenter | quote -}}
    {{- end -}}
{{- end -}}

{{/*
Create the cassandra keyspace
*/}}
{{- define "flink.cassandra.keyspace" -}}
    {{- if not .Values.cassandra.enabled -}}
        {{- .Values.externalDatabase.keyspace | quote -}}
    {{- else }}
        {{- .Values.cassandra.keyspace | quote -}}
    {{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "flink.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "flink.validateValues.cassandra" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/* Validate values of flink - Cassandra */}}
{{- define "flink.validateValues.cassandra" -}}
{{- if and .Values.cassandra.enabled .Values.externalDatabase.host -}}
flink: Cassandra
    You can only use one database.
    Please choose installing a Cassandra chart (--set cassandra.enabled=true) or
    using an external database (--set externalDatabase.host)
{{- end -}}
{{- if and (not .Values.cassandra.enabled) (not .Values.externalDatabase.host) -}}
flink: Cassandra
    You did not set any database.
    Please choose installing a Cassandra chart (--set mongodb.enabled=true) or
    using an external database (--set externalDatabase.host)
{{- end -}}
{{- end -}}
