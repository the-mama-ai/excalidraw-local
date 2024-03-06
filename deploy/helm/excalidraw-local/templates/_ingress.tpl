{{- define "project.ingress" -}}
{{- $params := . -}}
{{- $root := first $params -}}
{{- $scope := rest $params | first -}}
{{- $ingress := index $root.Values.ingress $scope -}}

{{- if $ingress.enabled -}}
  {{- $fullName := include "project.fullname" $root -}}
  {{- $svcPort := $root.Values.service.port -}}
  {{- if and $ingress.className (not (semverCompare ">=1.18-0" $root.Capabilities.KubeVersion.GitVersion)) }}
    {{- if not (hasKey $ingress.annotations "kubernetes.io/ingress.class") }}
    {{- $_ := set $ingress.annotations "kubernetes.io/ingress.class" $ingress.className}}
    {{- end }}
  {{- end }}
{{- if semverCompare ">=1.19-0" $root.Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1
{{- else if semverCompare ">=1.14-0" $root.Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1beta1
{{- else -}}
apiVersion: extensions/v1beta1
{{- end }}
kind: Ingress
metadata:
  name: {{ printf "%s-%s" $fullName $scope }}
  labels:
    {{- include "project.labels" $root | nindent 4 }}
  {{- with $ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if and $ingress.className (semverCompare ">=1.18-0" $root.Capabilities.KubeVersion.GitVersion) }}
  ingressClassName: {{ $ingress.className }}
  {{- end }}
  {{- if $ingress.tls }}
  tls:
    {{- range $ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range $ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            {{- if and .pathType (semverCompare ">=1.18-0" $root.Capabilities.KubeVersion.GitVersion) }}
            pathType: {{ .pathType }}
            {{- end }}
            backend:
              {{- if semverCompare ">=1.19-0" $root.Capabilities.KubeVersion.GitVersion }}
              service:
                name: {{ .service | default $fullName }}
                port:
                  number: {{ .servicePortNumber | default $svcPort }}
              {{- else }}
              serviceName: {{ .service | default $fullName }}
              servicePort: {{ .servicePortNumber | default $svcPort }}
              {{- end }}
          {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
