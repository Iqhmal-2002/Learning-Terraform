terraform {

}

variable "hello" {
    type = string
}

variable "cards" {
    type = list(string)
}

variable "types" {
    type = map(string)
}

variable "splat" {
    type = list(object({
        name = string
        type = string
    }))
}