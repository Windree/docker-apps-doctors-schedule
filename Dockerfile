FROM ubuntu
RUN apt update && apt install curl jq -y
ADD @ /
CMD "/init.sh"