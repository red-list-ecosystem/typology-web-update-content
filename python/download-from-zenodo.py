from zenodo_client import Zenodo
# pystow set zenodo api_token $(cat ~/.ZenodoToken)

zenodo = Zenodo()
GET_IM_RECORD = '3546513'
new_record = zenodo.get_latest_record(GET_IM_RECORD)
downloaded_files = zenodo.download_latest(new_record)

