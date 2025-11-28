data "template_file" "userdata" {
    template = base64encode(templatefile("${path.module}/userdata.yaml", {
  
  }))

}